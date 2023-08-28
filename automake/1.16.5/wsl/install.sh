FOLDER_NAME=automake
VERSION=1.16.5

AUTOCONF_FOLDER_NAME=autoconf
AUTOCONF_VERSION=2.71

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

	bash $INSTALL_FILES_DIR/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/wsl/install.sh

	export PATH=$HOME/programs/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/bin:$PATH

	cd $HOME/sources/$FOLDER_NAME

	wget "https://ftp.gnu.org/gnu/automake/automake-$VERSION.tar.gz"
	tar -xvf "automake-$VERSION.tar.gz"
	mv "automake-$VERSION" $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "automake-$VERSION.tar.gz"
fi

cd $HOME/install-files