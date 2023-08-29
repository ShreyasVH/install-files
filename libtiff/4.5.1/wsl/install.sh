FOLDER_NAME=libtiff
VERSION=4.5.1

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

	wget "http://download.osgeo.org/libtiff/tiff-$VERSION.tar.gz"
	tar -xvf "tiff-$VERSION.tar.gz"
	mv "tiff-$VERSION" $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "tiff-$VERSION.tar.gz"
fi
