FOLDER_NAME=proj
VERSION=9.2.1

CMAKE_FOLDER_NAME=cmake
CMAKE_VERSION=3.26.4

SQLITE_VERSION=3.42.0
SQLITE_FOLDER_NAME=sqlite3

LIBTIFF_VERSION=4.5.1
LIBTIFF_FOLDER_NAME=libtiff

CURL_VERSION=8.2.1
CURL_FOLDER_NAME=curl

OPENSSL_VERSION=3.0.10
OPENSSL_FOLDER_NAME=openssl

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

	bash $INSTALL_FILES_DIR/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$CURL_FOLDER_NAME/$CURL_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/macos/install.sh

	export LD_LIBRARY_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib:$LD_LIBRARY_PATH

	export PATH=$HOME/programs/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/bin:$PATH

	cd $HOME/sources/$FOLDER_NAME

	wget "https://download.osgeo.org/proj/proj-$VERSION.tar.gz"
	tar -xvf "proj-$VERSION.tar.gz"
	mv "proj-$VERSION" $VERSION
	cd $VERSION
	mkdir bld
	cd bld
	cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION -DCMAKE_PREFIX_PATH=$HOME/programs/$SQLITE_FOLDER_NAME/$SQLITE_VERSION -DTIFF_LIBRARY_RELEASE=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib/libtiff.dylib -DTIFF_INCLUDE_DIR=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/include -DCURL_LIBRARY=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/lib/libcurl.dylib -DCURL_INCLUDE_DIR=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/include
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	sudo rm -rf $VERSION
	rm "proj-$VERSION.tar.gz"
fi