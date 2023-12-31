FOLDER_NAME=python
VERSION=3.11.4

PKG_CONFIG_FOLDER_NAME=pkg-config
PKG_CONFIG_VERSION=0.29.2

GETTEXT_FOLDER_NAME=gettext
GETTEXT_VERSION=0.22

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=1.3

OPENSSL_VERSION=3.0.10
OPENSSL_FOLDER_NAME=openssl

LIBFFI_VERSION=3.4.4
LIBFFI_FOLDER_NAME=libffi

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

	bash $INSTALL_FILES_DIR/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$LIBFFI_FOLDER_NAME/$LIBFFI_VERSION/wsl/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH="$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH"

	export LDFLAGS="-L$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/lib"
	export CPPFLAGS="-I$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/include"

	export PKG_CONFIG_PATH=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export ZLIB_CFLAGS=$(pkg-config --cflags zlib)
	export ZLIB_LIBS=$(pkg-config --libs zlib)

	export PKG_CONFIG_PATH=$HOME/programs/$LIBFFI_FOLDER_NAME/$LIBFFI_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export CFLAGS=$(pkg-config --cflags libffi)
	export LDFLAGS=$(pkg-config --libs libffi)

	wget "https://www.python.org/ftp/python/"$VERSION"/Python-"$VERSION".tgz"
	tar -xvf "Python-"$VERSION".tgz"
	mv "Python-"$VERSION $VERSION
	cd $VERSION
	./configure --with-pydebug --prefix="$HOME/programs/python/$VERSION" --with-openssl=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION
	make -s -j2
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	sudo rm -rf $VERSION
	rm "Python-"$VERSION".tgz"
fi
