VERSION=2.10.4
FOLDER_NAME=libxml2
MINOR_VERSION=2.10

PKG_CONFIG_VERSION=0.29.2
PKG_CONFIG_FOLDER_NAME=pkg-config

PYTHON_VERSION=3.11.4
PYTHON_FOLDER_NAME=python
PYTHON_MINOR_VERSION=3.11

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

	bash $INSTALL_FILES_DIR/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH
	export PATH=$HOME/programs/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/bin:$PATH
	export PKG_CONFIG_PATH=$HOME/programs/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PYTHON_CFLAGS="-I$HOME/programs/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/include/python3.11d"

	wget "https://download.gnome.org/sources/libxml2/$MINOR_VERSION/libxml2-$VERSION.tar.xz"
	tar -xvf "libxml2-$VERSION.tar.xz"
	mv "libxml2-$VERSION" $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "libxml2-$VERSION.tar.xz"
fi

cd $HOME/install-files