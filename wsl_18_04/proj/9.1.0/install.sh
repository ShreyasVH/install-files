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

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libproj.so" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$CURL_FOLDER_NAME/$CURL_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/install.sh $((DEPTH+1))

	export LD_LIBRARY_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib:$LD_LIBRARY_PATH

	export PATH=$HOME/programs/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/bin:$PATH

	cd $HOME/sources/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="proj-$VERSION.tar.gz"
	wget -q "https://download.osgeo.org/proj/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "proj-$VERSION" $VERSION
	cd $VERSION
	mkdir bld
	cd bld
	print_message "${bold}${green}Running cmake${clear}" $((DEPTH))
	cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION -DCMAKE_PREFIX_PATH=$HOME/programs/$SQLITE_FOLDER_NAME/$SQLITE_VERSION -DTIFF_LIBRARY_RELEASE=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib/libtiff.so -DTIFF_INCLUDE_DIR=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/include -DCURL_LIBRARY=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/lib/libcurl.so -DCURL_INCLUDE_DIR=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/include > $HOME/logs/$FOLDER_NAME/$VERSION/cmakeOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libproj.so" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi