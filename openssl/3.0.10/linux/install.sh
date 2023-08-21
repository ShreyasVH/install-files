FOLDER_NAME=openssl
VERSION=3.0.10

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

	cd $HOME/sources/openssl

	make clean distclean

	wget "https://www.openssl.org/source/openssl-$VERSION.tar.gz"
	tar -xvf "openssl-$VERSION.tar.gz"
	mv "openssl-$VERSION" $VERSION
	cd $VERSION

	./config --prefix=$HOME/programs/openssl/$VERSION --libdir=lib shared zlib-dynamic
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
	rm "openssl-$VERSION.tar.gz"
fi

cd $HOME/install-files