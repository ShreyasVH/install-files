FOLDER_NAME=proj
VERSION=9.1.0

cd $INSTALL_FILES_DIR

CMAKE_FOLDER_NAME=cmake
CMAKE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$CMAKE_FOLDER_NAME" '.[$folder][$version][$name]')

SQLITE_FOLDER_NAME=sqlite3
SQLITE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$SQLITE_FOLDER_NAME" '.[$folder][$version][$name]')

LIBTIFF_FOLDER_NAME=libtiff
LIBTIFF_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBTIFF_FOLDER_NAME" '.[$folder][$version][$name]')

CURL_FOLDER_NAME=curl
CURL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$CURL_FOLDER_NAME" '.[$folder][$version][$name]')

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libproj.so" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$CURL_FOLDER_NAME/$CURL_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/wsl/install.sh

	export LD_LIBRARY_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib:$LD_LIBRARY_PATH

	export PATH=$HOME/programs/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/bin:$PATH

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="proj-$VERSION.tar.gz"
	wget -q --show-progress "https://download.osgeo.org/proj/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "proj-$VERSION" $VERSION
	cd $VERSION
	mkdir bld
	cd bld
	printf "\t${bold}${green}Running cmake${clear}\n"
	cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION -DCMAKE_PREFIX_PATH=$HOME/programs/$SQLITE_FOLDER_NAME/$SQLITE_VERSION -DTIFF_LIBRARY_RELEASE=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib/libtiff.so -DTIFF_INCLUDE_DIR=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/include -DCURL_LIBRARY=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/lib/libcurl.so -DCURL_INCLUDE_DIR=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/include > $HOME/logs/$FOLDER_NAME/$VERSION/cmakeOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libproj.so" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi