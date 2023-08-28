FOLDER_NAME=autoconf
VERSION=2.71

M4_FOLDER_NAME=m4
M4_VERSION=1.4.19

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

	bash $INSTALL_FILES_DIR/$M4_FOLDER_NAME/$M4_VERSION/wsl/install.sh

	export PATH=$HOME/programs/$M4_FOLDER_NAME/$M4_VERSION/bin:$PATH

	cd $HOME/sources/$FOLDER_NAME

	wget -q "https://ftp.gnu.org/gnu/autoconf/autoconf-$VERSION.tar.gz"
	tar -xvf "autoconf-$VERSION.tar.gz"
	mv "autoconf-$VERSION" $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "autoconf-$VERSION.tar.gz"
fi