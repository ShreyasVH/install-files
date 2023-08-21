FOLDER_NAME=gmp
VERSION=6.2.1

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

	wget "https://ftp.gnu.org/gnu/gmp/gmp-$VERSION.tar.xz"
	tar -xvf "gmp-$VERSION.tar.xz"
	mv "gmp-"$VERSION $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --disable-static
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "gmp-$VERSION.tar.xz"
fi

cd $HOME/install-files