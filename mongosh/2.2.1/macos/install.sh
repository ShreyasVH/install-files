FOLDER_NAME=mongosh
VERSION=2.2.1

cd $INSTALL_FILES_DIR

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://downloads.mongodb.com/compass/mongosh-$VERSION-darwin-arm64.zip"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	unzip "mongosh-$VERSION-darwin-arm64.zip" > /dev/null 2>&1
	mv "mongosh-$VERSION-darwin-arm64" $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mongosh" ]; then
		cd $VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t${bold}${green}Clearing${clear}\n"
		cd ..
		rm "mongosh-$VERSION-darwin-arm64.zip"
	fi
fi

cd $HOME/install-files