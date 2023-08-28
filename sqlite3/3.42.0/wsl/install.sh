VERSION=3.42.0
FOLDER_NAME=sqlite3
VERSION_FULLFORM=3420000
VERSION_YEAR=2023

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

	wget -q "https://www.sqlite.org/$VERSION_YEAR/sqlite-autoconf-$VERSION_FULLFORM.tar.gz"
	tar -xvf "sqlite-autoconf-$VERSION_FULLFORM.tar.gz"
	mv "sqlite-autoconf-"$VERSION_FULLFORM $VERSION
	cd $VERSION
	ls
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --disable-static
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "sqlite-autoconf-$VERSION_FULLFORM.tar.gz"
fi