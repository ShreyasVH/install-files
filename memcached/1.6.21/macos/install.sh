VERSION=1.6.21
FOLDER_NAME=memcached

LIBEVENT_FOLDER_NAME=libevent
LIBEVENT_VERSION=2.1.12

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

	bash $INSTALL_FILES_DIR/$LIBEVENT_FOLDER_NAME/$LIBEVENT_VERSION/macos/install.sh

	cd "$HOME/sources/$FOLDER_NAME"

	wget "https://memcached.org/files/memcached-$VERSION.tar.gz"
	tar -xvf "memcached-$VERSION.tar.gz"
	mv "memcached-$VERSION" $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-libevent=$HOME/programs/$LIBEVENT_FOLDER_NAME/$LIBEVENT_VERSION
	make
	sudo make install


	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "memcached-$VERSION.tar.gz"
fi