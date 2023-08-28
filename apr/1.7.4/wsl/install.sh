FOLDER_NAME=apr
VERSION=1.7.4

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

	make clean distclean

	wget -q "https://archive.apache.org/dist/apr/apr-"$VERSION".tar.gz"
	tar -xvf "apr-"$VERSION".tar.gz"
	mv "apr-"$VERSION $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/apr/$VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "apr-"$VERSION".tar.gz"
fi

cd $HOME/install-files