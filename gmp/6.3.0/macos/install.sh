FOLDER_NAME=gmp
VERSION=6.3.0

cd $INSTALL_FILES_DIR

M4_FOLDER_NAME=m4
M4_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$M4_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libgmp.dylib" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$M4_FOLDER_NAME/$M4_VERSION/macos/install.sh

	export PATH=$HOME/programs/$M4_FOLDER_NAME/$M4_VERSION/bin:$PATH

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="gmp-$VERSION.tar.xz"
	wget -q --show-progress "https://ftp.gnu.org/gnu/gmp/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "gmp-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --disable-static > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libgmp.dylib" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files