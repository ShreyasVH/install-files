version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)

program_dir=$(dirname "$version_dir")
FOLDER_NAME=$(basename $program_dir)

os_dir=$(dirname $program_dir)
OS=$(basename $os_dir)

DEPTH=2
if [ $# -ge 2 ]; then
    DEPTH=$2
fi

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ $# -lt 1 ]; then
    printf "${bold}${red}Usage: $0 <arg1>${clear}"
    exit 1
fi

POSTGRES_FOLDER_NAME=postgres
POSTGRES_VERSION=$1

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

GETTEXT_FOLDER_NAME=gettext
GETTEXT_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$GETTEXT_FOLDER_NAME" '.[$folder][$version][$name]')

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ZLIB_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/lib/postgis-3.so" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$LIBXML_FOLDER_NAME/$LIBXML_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$GEOS_FOLDER_NAME/$GEOS_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$PROJ_FOLDER_NAME/$PROJ_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$CURL_FOLDER_NAME/$CURL_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/install.sh $((DEPTH+1))

	export PATH=$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/bin:$PATH
	export PATH=$HOME/programs/$LIBXML_FOLDER_NAME/$LIBXML_VERSION/bin:$PATH
	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH

	export LD_LIBRARY_PATH=$HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib:$LD_LIBRARY_PATH
	export LD_LIBRARY_PATH=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib:$LD_LIBRARY_PATH
	export LD_LIBRARY_PATH=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib:$LD_LIBRARY_PATH

	export PKG_CONFIG_PATH=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH

	export PKG_CONFIG_PATH=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PROJ_CFLAGS=$(pkg-config --cflags proj)
	export PROJ_LIBS=$(pkg-config --libs proj)

	export CFLAGS="-I$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/include $CFLAGS"

	cd $HOME/sources/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="postgis-$VERSION.tar.gz"
	wget -q "https://postgis.net/stuff/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "postgis-$VERSION" $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION --with-projdir=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION --with-geosconfig=$HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/bin/geos-config --without-protobuf --without-raster --with-gettext=$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION --with-libintl-prefix=$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION --disable-rpath --without-raster --without-topology > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/lib/postgis-3.so" ]; then
		cd $HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		cd $HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION
		echo "export LD_LIBRARY_PATH=\$HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib:\$LD_LIBRARY_PATH" | cat - start.sh > temp && mv temp start.sh
		echo "export LD_LIBRARY_PATH=\$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib:\$LD_LIBRARY_PATH" | cat - start.sh > temp && mv temp start.sh
		echo "export LD_LIBRARY_PATH=\$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib:\$LD_LIBRARY_PATH" | cat - start.sh > temp && mv temp start.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi

cd $HOME/install-files