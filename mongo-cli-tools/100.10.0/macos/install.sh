FOLDER_NAME=mongo-cli-tools
VERSION=100.10.0

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mongoexport" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0
	
	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-macos-arm64-$VERSION.zip"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	unzip "mongodb-database-tools-macos-arm64-$VERSION.zip" > /dev/null 2>&1
	mv "mongodb-database-tools-macos-arm64-$VERSION" $VERSION
	cd $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mongoexport" ]; then
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t${bold}${green}Clearing${clear}\n"
		cd ..
		rm "mongodb-database-tools-macos-arm64-$VERSION.zip"
	fi
fi

cd $HOME/install-files