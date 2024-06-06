VERSION=3.46.0
FOLDER_NAME=sqlite3
VERSION_FULLFORM=3460000
VERSION_YEAR=2024

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/sqlite3" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="sqlite-autoconf-$VERSION_FULLFORM.tar.gz"
	wget -q --show-progress "https://www.sqlite.org/$VERSION_YEAR/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "sqlite-autoconf-"$VERSION_FULLFORM $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --disable-static > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/sqlite3" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		direnv allow

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi