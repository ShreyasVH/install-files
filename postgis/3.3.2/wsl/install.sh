FOLDER_NAME=postgis
VERSION=3.3.2

if [ $# -lt 1 ]; then
    printf "${bold}${red}Usage: $0 <arg1>${clear}"
    exit 1
fi

POSTGRES_FOLDER_NAME=postgres
POSTGRES_VERSION=$1

cd $INSTALL_FILES_DIR

LIBXML_FOLDER_NAME=libxml2
LIBXML_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBXML_FOLDER_NAME" '.[$folder][$version][$name]')

GEOS_FOLDER_NAME=geos
GEOS_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$GEOS_FOLDER_NAME" '.[$folder][$version][$name]')

PROJ_FOLDER_NAME=proj
PROJ_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PROJ_FOLDER_NAME" '.[$folder][$version][$name]')

PKG_CONFIG_FOLDER_NAME="pkg-config"
PKG_CONFIG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PKG_CONFIG_FOLDER_NAME" '.[$folder][$version][$name]')

SQLITE_FOLDER_NAME=sqlite3
SQLITE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$SQLITE_FOLDER_NAME" '.[$folder][$version][$name]')

LIBTIFF_FOLDER_NAME=libtiff
LIBTIFF_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBTIFF_FOLDER_NAME" '.[$folder][$version][$name]')

CURL_FOLDER_NAME=curl
CURL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$CURL_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/lib/postgis-3.so" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$LIBXML_FOLDER_NAME/$LIBXML_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$GEOS_FOLDER_NAME/$GEOS_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$PROJ_FOLDER_NAME/$PROJ_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$CURL_FOLDER_NAME/$CURL_VERSION/wsl/install.sh
	
	export PATH=$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/bin:$PATH
	export PATH=$HOME/programs/$LIBXML_FOLDER_NAME/$LIBXML_VERSION/bin:$PATH
	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH

	export LD_LIBRARY_PATH=$HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib:$LD_LIBRARY_PATH
	export LD_LIBRARY_PATH=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib:$LD_LIBRARY_PATH
	export LD_LIBRARY_PATH=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib:$LD_LIBRARY_PATH

	export PKG_CONFIG_PATH=$HOME/programs/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH

	export PKG_CONFIG_PATH=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PROJ_CFLAGS=$(pkg-config --cflags proj)
	export PROJ_LIBS=$(pkg-config --libs proj)
	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="postgis-$VERSION.tar.gz"
	wget -q --show-progress "https://postgis.net/stuff/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "postgis-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION --with-projdir=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION --with-geosconfig=$HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/bin/geos-config --without-protobuf --without-raster > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/lib/postgis-3.so" ]; then
		cd $HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION

		echo "" | cat - start.sh > temp && mv temp start.sh
		echo 'export LD_LIBRARY_PATH=$HOME'"/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib:"'$LD_LIBRARY_PATH' | cat - start.sh > temp && mv temp start.sh
		echo "" | cat - start.sh > temp && mv temp start.sh
		echo 'export LD_LIBRARY_PATH=$HOME'"/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib:"'$LD_LIBRARY_PATH' | cat - start.sh > temp && mv temp start.sh
		echo "" | cat - start.sh > temp && mv temp start.sh
		echo 'export LD_LIBRARY_PATH=$HOME'"/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib:"'$LD_LIBRARY_PATH' | cat - start.sh > temp && mv temp start.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files