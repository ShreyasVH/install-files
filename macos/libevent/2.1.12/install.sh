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

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$STATIC_VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

PKG_CONFIG_FOLDER_NAME="pkg-config"
PKG_CONFIG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PKG_CONFIG_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libevent.dylib" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/install.sh $((DEPTH+1))

	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH

	cd "$HOME/sources/$FOLDER_NAME"

	export PKG_CONFIG_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="libevent-$VERSION-stable.tar.gz"
	wget -q "https://github.com/libevent/libevent/releases/download/release-$VERSION-stable/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "libevent-$VERSION-stable" $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libevent.dylib" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .
		
		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi