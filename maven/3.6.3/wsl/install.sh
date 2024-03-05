VERSION=3.6.3
FOLDER_NAME=maven
MAJOR_VERSION=3

cd $INSTALL_FILES_DIR

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0
	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://archive.apache.org/dist/maven/maven-$MAJOR_VERSION/$VERSION/binaries/apache-maven-$VERSION-bin.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "apache-maven-$VERSION-bin.tar.gz"
	mv "apache-maven-"$VERSION $VERSION

	cd $VERSION
	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	printf "\t${bold}${green}Clearing${clear}\n"
	cd ..
	rm "apache-maven-$VERSION-bin.tar.gz"
fi
