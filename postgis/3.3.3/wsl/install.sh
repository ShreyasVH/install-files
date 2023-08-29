FOLDER_NAME=postgis
VERSION=3.3.3

POSTGRES_FOLDER_NAME=postgres
POSTGRES_VERSION=15.4

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

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
	mkdir "$HOME/sources/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

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
	sudo ldconfig
	export LD_LIBRARY_PATH=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib:$LD_LIBRARY_PATH

	export PKG_CONFIG_PATH=$HOME/programs/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH

	export PKG_CONFIG_PATH=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PROJ_CFLAGS=$(pkg-config --cflags proj)
	export PROJ_LIBS=$(pkg-config --libs proj)

	cd $HOME/sources/$FOLDER_NAME

	wget "https://postgis.net/stuff/postgis-$VERSION.tar.gz"
	tar -xvf "postgis-$VERSION.tar.gz"
	mv "postgis-$VERSION" $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-geosconfig=$HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/bin/geos-config --without-protobuf --without-raster
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "postgis-$VERSION.tar.gz"
fi

cd $HOME/install-files