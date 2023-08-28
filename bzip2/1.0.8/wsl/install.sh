FOLDER_NAME=bzip2
VERSION=1.0.8

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

	wget "https://sourceware.org/pub/bzip2/bzip2-$VERSION.tar.gz"
	tar -xvf "bzip2-$VERSION.tar.gz"
	mv "bzip2-$VERSION" $VERSION
	cd $VERSION
	make clean distclean
	make -f Makefile-libbz2_so
	sudo make install PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "bzip2-$VERSION.tar.gz"
fi

cd $HOME/install-files