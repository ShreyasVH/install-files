FOLDER_NAME=geos
VERSION=3.12.0

CMAKE_FOLDER_NAME=cmake
CMAKE_VERSION=3.26.4

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

	bash $INSTALL_FILES_DIR/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/wsl/install.sh

	export PATH=$HOME/programs/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/bin:$PATH

	cd $HOME/sources/$FOLDER_NAME

	wget "https://download.osgeo.org/geos/geos-$VERSION.tar.bz2"
	tar -xvf "geos-$VERSION.tar.bz2"
	mv "geos-$VERSION" $VERSION
	cd $VERSION
	mkdir bld
	cd bld
	cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "geos-$VERSION.tar.bz2"
fi