FOLDER_NAME=node
VERSION=16.3.0

PYTHON_FOLDER_NAME=python
PYTHON_VERSION=3.9.18

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

	bash $INSTALL_FILES_DIR/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/wsl/install.sh
	export PATH=$HOME/programs/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/bin:$PATH

	cd $HOME/sources/$FOLDER_NAME

	wget -q "https://nodejs.org/dist/v"$VERSION"/node-v"$VERSION".tar.gz"
	tar -xvf "node-v"$VERSION".tar.gz"
	mv "node-v"$VERSION $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
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
	rm "node-v"$VERSION".tar.gz"
fi
