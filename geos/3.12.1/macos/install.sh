FOLDER_NAME=geos
VERSION=3.12.1

cd $INSTALL_FILES_DIR

CMAKE_FOLDER_NAME=cmake
CMAKE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$CMAKE_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libgeos.dylib" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/macos/install.sh

	export PATH=$HOME/programs/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/bin:$PATH

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="geos-$VERSION.tar.bz2"
	wget -q --show-progress "https://download.osgeo.org/geos/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "geos-$VERSION" $VERSION
	cd $VERSION
	mkdir bld
	cd bld
	printf "\t${bold}${green}Running cmake${clear}\n"
	cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/cmakeOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libgeos.dylib" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi