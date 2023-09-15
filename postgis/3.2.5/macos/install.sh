FOLDER_NAME=postgis
VERSION=3.2.5

POSTGRES_FOLDER_NAME=postgres
POSTGRES_VERSION=15.3

LIBXML_VERSION=2.10.4
LIBXML_FOLDER_NAME=libxml2

GEOS_VERSION=3.12.0
GEOS_FOLDER_NAME=geos

PROJ_VERSION=9.2.1
PROJ_FOLDER_NAME=proj

PKG_CONFIG_VERSION=0.29.2
PKG_CONFIG_FOLDER_NAME="pkg-config"

SQLITE_VERSION=3.42.0
SQLITE_FOLDER_NAME=sqlite3

LIBTIFF_VERSION=4.5.1
LIBTIFF_FOLDER_NAME=libtiff

CURL_VERSION=8.2.1
CURL_FOLDER_NAME=curl

GETTEXT_FOLDER_NAME=gettext
GETTEXT_VERSION=0.22

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=1.3

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/logs" ]; then
	mkdir "$HOME/logs"
fi

if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
	mkdir "$HOME/sources/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	bash $INSTALL_FILES_DIR/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$LIBXML_FOLDER_NAME/$LIBXML_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$GEOS_FOLDER_NAME/$GEOS_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$PROJ_FOLDER_NAME/$PROJ_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$CURL_FOLDER_NAME/$CURL_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/macos/install.sh

	export PATH=$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/bin:$PATH
	export PATH=$HOME/programs/$LIBXML_FOLDER_NAME/$LIBXML_VERSION/bin:$PATH
	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH

	export DYLD_LIBRARY_PATH=$HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib:$DYLD_LIBRARY_PATH
	export DYLD_LIBRARY_PATH=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib:$DYLD_LIBRARY_PATH

	export PKG_CONFIG_PATH=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH

	export PKG_CONFIG_PATH=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PROJ_CFLAGS=$(pkg-config --cflags proj)
	export PROJ_LIBS=$(pkg-config --libs proj)

	export CFLAGS="-I$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/include $CFLAGS"

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://postgis.net/stuff/postgis-$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "postgis-$VERSION.tar.gz"
	mv "postgis-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION --with-projdir=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION --with-geosconfig=$HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/bin/geos-config --without-protobuf --without-raster --with-gettext=$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION --with-libintl-prefix=$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION --disable-rpath > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	printf "\t${bold}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S -p '' make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	if [ -e "$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/lib/postgis-3.so" ]; then
		install_name_tool -change @rpath/libgeos_c.1.dylib $HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib/libgeos_c.1.dylib $HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/lib/postgis-3.so
		install_name_tool -change @rpath/libproj.25.dylib $HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib/libproj.25.dylib $HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/lib/postgis-3.so
		install_name_tool -change @rpath/libgeos.3.12.0.dylib $HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib/libgeos.3.12.0.dylib $HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib/libgeos_c.1.18.0.dylib

		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "postgis-$VERSION.tar.gz"
	fi
fi

cd $HOME/install-files