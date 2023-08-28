FOLDER_NAME=ncurses
VERSION=6.4

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

if [ ! -d "$HOME/programs/$BOOST_FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$BOOST_FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	cd $HOME/sources/$FOLDER_NAME

	wget -q "https://ftp.gnu.org/gnu/ncurses/ncurses-$VERSION.tar.gz"
	tar -xvf "ncurses-$VERSION.tar.gz"
	mv "ncurses-$VERSION" $VERSION
	cd $VERSION

	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "ncurses-$VERSION.tar.gz"
fi

cd $HOME/install-files