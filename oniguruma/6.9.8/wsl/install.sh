VERSION=6.9.8
FOLDER_NAME=oniguruma

AUTOCONF_VERSION=2.71
AUTOCONF_FOLDER_NAME=autoconf

AUTOMAKE_VERSION=1.16.5
AUTOMAKE_FOLDER_NAME=automake

LIBTOOL_VERSION=2.4.7
LIBTOOL_FOLDER_NAME=libtool

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

	bash $INSTALL_FILES_DIR/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$AUTOMAKE_FOLDER_NAME/$AUTOMAKE_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$LIBTOOL_FOLDER_NAME/$LIBTOOL_VERSION/wsl/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/bin:$PATH
	export PATH=$HOME/programs/$AUTOMAKE_FOLDER_NAME/$AUTOMAKE_VERSION/bin:$PATH
	export PATH=$HOME/programs/$LIBTOOL_FOLDER_NAME/$LIBTOOL_VERSION/bin:$PATH
	export LIBTOOL=$HOME/programs/$LIBTOOL_FOLDER_NAME/$LIBTOOL_VERSION/bin/libtool

	wget "https://github.com/kkos/oniguruma/releases/download/v$VERSION/onig-$VERSION.tar.gz"
	tar -xvf "onig-$VERSION.tar.gz"
	mv "onig-"$VERSION $VERSION
	cd $VERSION
	# libtoolize
	aclocal
	autoconf
	automake --add-missing --copy
	autoreconf -vfi
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
	make
	sudo make install
fi

cd $HOME/install-files