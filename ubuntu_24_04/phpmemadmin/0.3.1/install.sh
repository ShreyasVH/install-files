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
PHP_VERSION=$(cat "$STATIC_VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PHP_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/.config ]; then
	print_message ".config not found" $((DEPTH))
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/web/index.php" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$PHP_FOLDER_NAME/$PHP_VERSION/install.sh $((DEPTH+1))

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE=v$VERSION.tar.gz
	wget -q "https://github.com/clickalicious/phpmemadmin/archive/refs/tags/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "phpmemadmin-$VERSION" $VERSION
	cd $VERSION

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$PHP_FOLDER_NAME/$PHP_VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	touch start.sh
	PORT=1408
	echo "php -S '0.0.0.0:$PORT' -t web > phpmemadmin.log 2>&1 &" >> start.sh

	touch stop.sh
	echo 'kill -9 $(lsof -t -i:'$PORT')' >> stop.sh

	mv app/.config.dist ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/.config.dist
	ln -s ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/.config ./app/

	export PATH=$HOME/programs/$PHP_FOLDER_NAME/$PHP_VERSION/bin:$PATH
	print_message "${bold}${green}Running composer install${clear}" $((DEPTH))
	composer require --dev satooshi/php-coveralls:"~1.0.1" --no-update > /dev/null 2>&1
	composer -q install

	print_message "${bold}${green}Clearing${clear}" $((DEPTH))
	cd ..
	rm $ARCHIVE_FILE
fi