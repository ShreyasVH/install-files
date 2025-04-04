FOLDER_NAME=node
VERSION=22.9.0

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/node" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://nodejs.org/dist/v$VERSION/node-v$VERSION-darwin-arm64.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "node-v$VERSION-darwin-arm64.tar.gz"
	mv "node-v$VERSION-darwin-arm64" $VERSION
	cd $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/node" ]; then
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t${bold}${green}Clearing${clear}\n"
		cd ..
		rm "node-v$VERSION-darwin-arm64.tar.gz"
	fi
fi

cd $HOME/install-files
