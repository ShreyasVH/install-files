FOLDER_NAME=libffi
VERSION=3.4.4

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

	cd $HOME/sources/$FOLDER_NAME

	wget "https://github.com/libffi/libffi/releases/download/v$VERSION/libffi-$VERSION.tar.gz"
	tar -xvf "libffi-$VERSION.tar.gz"
	mv "libffi-$VERSION" $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	# cd $HOME/sources/$FOLDER_NAME
	# rm -rf $VERSION
	# rm "libffi-$VERSION.tar.gz"
fi

cd $HOME/install-files



