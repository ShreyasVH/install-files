# FOLDER_NAME=libtiff
# VERSION=4.5.1

# if [ ! -d "$HOME/sources" ]; then
# 	mkdir "$HOME/sources"
# fi

# if [ ! -d "$HOME/programs" ]; then
# 	mkdir "$HOME/programs"
# fi

# if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
# 	mkdir "$HOME/sources/$FOLDER_NAME"
# fi

# if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
# 	mkdir "$HOME/programs/$FOLDER_NAME"
# fi

# if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
# 	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

# 	cd $HOME/sources/$FOLDER_NAME

# 	wget "http://download.osgeo.org/libtiff/tiff-$VERSION.tar.gz"
# 	tar -xvf "tiff-$VERSION.tar.gz"
# 	mv "tiff-$VERSION" $VERSION
# 	cd $VERSION
# 	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
# 	make
# 	sudo make install

# 	cd $HOME/programs/$FOLDER_NAME/$VERSION
# 	sudo chown -R $(whoami) .

# 	cd $HOME/sources/$FOLDER_NAME
# 	rm -rf $VERSION
# 	rm "tiff-$VERSION.tar.gz"
# fi


FOLDER_NAME=libtiff
VERSION=4.5.0

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libtiff.so" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="tiff-$VERSION.tar.gz"
	wget -q --show-progress "http://download.osgeo.org/libtiff/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "tiff-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libtiff.so" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi
