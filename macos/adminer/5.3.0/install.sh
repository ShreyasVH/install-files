version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)

program_dir=$(dirname "$version_dir")
FOLDER_NAME=$(basename $program_dir)

os_dir=$(dirname $program_dir)
OS=$(basename $os_dir)

DEPTH=1
if [ $# -ge 1 ]; then
    DEPTH=$1
fi

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

PHP_FOLDER_NAME=php
PHP_VERSION=8.2.14

UNIXODBC_FOLDER_NAME=unixodbc
UNIXODBC_VERSION=2.3.12

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=3.2.0

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/index.php" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$PHP_FOLDER_NAME/$PHP_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$UNIXODBC_FOLDER_NAME/$UNIXODBC_VERSION/install.sh $((DEPTH+1))

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE=adminer-$VERSION.php
	wget -q "https://github.com/vrana/adminer/releases/download/v$VERSION/$ARCHIVE_FILE"
	mkdir $VERSION
	mv "adminer-$VERSION.php" "$VERSION/index.php"
	cd $VERSION

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	export PATH=$HOME/programs/$PHP_FOLDER_NAME/$PHP_VERSION/bin:$PATH
	php -r '$file = "index.php"; $data = file_get_contents($file); $data = str_replace("\"UID\"=>\$V,\"PWD\"=>\$F,\"CharacterSet\"=>\"UTF-8\"", "\"UID\"=>\$V,\"PWD\"=>\$F,\"CharacterSet\"=>\"UTF-8\",\"TrustServerCertificate\"=>true", $data); file_put_contents($file, $data);'

	touch .envrc
	echo 'export DYLD_LIBRARY_PATH=$HOME/programs/unixodbc/'$UNIXODBC_VERSION'/lib:$DYLD_LIBRARY_PATH' >> .envrc
	echo 'export DYLD_LIBRARY_PATH=$HOME/programs/openssl/'$OPENSSL_VERSION'/lib:$DYLD_LIBRARY_PATH' >> .envrc
	echo 'export PATH=$HOME/programs/'"$PHP_FOLDER_NAME/$PHP_VERSION/bin:"'$PATH' >> .envrc
	direnv allow

	touch start.sh
	PORT=1424
	echo 'export DYLD_LIBRARY_PATH=$HOME/programs/unixodbc/'$UNIXODBC_VERSION'/lib:$DYLD_LIBRARY_PATH' >> start.sh
	echo 'export DYLD_LIBRARY_PATH=$HOME/programs/openssl/'$OPENSSL_VERSION'/lib:$DYLD_LIBRARY_PATH' >> start.sh
	echo "php -S '0.0.0.0:$PORT' -t . > adminer.log 2>&1 &" >> start.sh

	touch stop.sh
	echo 'kill -9 $(lsof -t -i:'$PORT')' >> stop.sh
fi