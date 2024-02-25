# VERSION=4.4.1
# FOLDER_NAME=make

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

# 	wget -q "https://ftp.gnu.org/gnu/make/make-$VERSION.tar.gz"
# 	tar -xvf "make-$VERSION.tar.gz"
# 	mv "make-$VERSION" $VERSION
# 	cd $VERSION
# 	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
# 	make
# 	sudo make install

# 	cd $HOME/programs/$FOLDER_NAME/$VERSION
# 	sudo chown -R $(whoami) .

# 	cd $HOME/sources/$FOLDER_NAME
# 	rm -rf $VERSION
# 	rm "make-$VERSION.tar.gz"
# fi

# cd $HOME/install-files

VERSION=4.4.1
FOLDER_NAME=make

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/make" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="make-$VERSION.tar.gz"
	wget -q --show-progress "https://ftp.gnu.org/gnu/make/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "make-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/make" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files
