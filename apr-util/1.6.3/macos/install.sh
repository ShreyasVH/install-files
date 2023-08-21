FOLDER_NAME=apr-util
VERSION=1.6.3

APR_FOLDER_NAME=apr
APR_VERSION=1.7.4

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

	bash ../../$APR_FOLDER_NAME/$APR_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	make clean distclean

	wget "https://archive.apache.org/dist/apr/apr-util-"$VERSION".tar.gz"
	tar -xvf "apr-util-"$VERSION".tar.gz"
	mv "apr-util-"$VERSION $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-apr=$HOME/programs/apr/$APR_VERSION/bin/apr-1-config
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
	rm "apr-util-"$VERSION".tar.gz"
fi

cd $HOME/install-files