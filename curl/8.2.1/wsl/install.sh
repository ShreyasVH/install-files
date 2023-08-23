FOLDER_NAME=curl
VERSION=8.2.1

OPENSSL_VERSION=3.0.10
OPENSSL_FOLDER_NAME=openssl

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

	bash ../../$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/wsl/install.sh

	cd $HOME/sources/$FOLDER_NAME

	make clean distclean

	wget "https://curl.se/download/curl-$VERSION.tar.gz"
	tar -xvf "curl-$VERSION.tar.gz"
	mv "curl-$VERSION" $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-openssl=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "curl-$VERSION.tar.gz"
fi

cd $HOME/install-files