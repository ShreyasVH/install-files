FOLDER_NAME=cmake
VERSION=3.26.4

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=3.0.10

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

	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/wsl/install.sh

	cd $HOME/sources/$FOLDER_NAME

	wget "https://github.com/Kitware/CMake/releases/download/v$VERSION/cmake-$VERSION.tar.gz"
	tar -xvf "cmake-$VERSION.tar.gz"
	mv "cmake-"$VERSION $VERSION
	cd $VERSION
	export OPENSSL_ROOT_DIR=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION
	./bootstrap --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "cmake-$VERSION.tar.gz"
fi

cd $HOME/install-files