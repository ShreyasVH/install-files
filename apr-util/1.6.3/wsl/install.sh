FOLDER_NAME=apr-util
VERSION=1.6.3

APR_FOLDER_NAME=apr
APR_VERSION=1.7.4

LIBEXPAT_FOLDER_NAME=libexpat
LIBEXPAT_VERSION=2.4.1

INSTALL_FILES_DIR=$HOME/install-files

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

	bash $INSTALL_FILES_DIR/$APR_FOLDER_NAME/$APR_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$LIBEXPAT_FOLDER_NAME/$LIBEXPAT_VERSION/wsl/install.sh

	cd $HOME/sources/$FOLDER_NAME

	wget -q "https://archive.apache.org/dist/apr/apr-util-"$VERSION".tar.gz"
	tar -xvf "apr-util-"$VERSION".tar.gz"
	mv "apr-util-"$VERSION $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-apr=$HOME/programs/apr/$APR_VERSION/bin/apr-1-config --with-expat=$HOME/programs/$LIBEXPAT_FOLDER_NAME/$LIBEXPAT_VERSION
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