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

LIBICONV_FOLDER_NAME=libiconv
LIBICONV_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBICONV_FOLDER_NAME" '.[$folder][$version][$name]')

GZIP_FOLDER_NAME=gzip
GZIP_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$GZIP_FOLDER_NAME" '.[$folder][$version][$name]')

XZ_FOLDER_NAME=xz
XZ_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$XZ_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/tar" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$LIBICONV_FOLDER_NAME/$LIBICONV_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$GZIP_FOLDER_NAME/$GZIP_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$XZ_FOLDER_NAME/$XZ_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	export LDFLAGS="-L$HOME/programs/$LIBICONV_FOLDER_NAME/$LIBICONV_VERSION/lib -liconv"
	export CPPFLAGS="-I$HOME/programs/$LIBICONV_FOLDER_NAME/$LIBICONV_VERSION/include"

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="tar-$VERSION.tar.gz"
	wget --show-progress "https://ftp.gnu.org/gnu/tar/$ARCHIVE_FILE" > $HOME/logs/$FOLDER_NAME/$VERSION/download.txt 2>&1
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "tar-$VERSION" $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-libiconv-prefix=$HOME/programs/$LIBICONV_FOLDER_NAME/$LIBICONV_VERSION --with-gzip=$HOME/programs/$GZIP_FOLDER_NAME/$GZIP_VERSION/bin/gzip --with-xz=$HOME/programs/$XZ_FOLDER_NAME/$XZ_VERSION/bin/xz > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/tar" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi