FOLDER_NAME=dotnet-core
VERSION=8.0.301

cd $INSTALL_FILES_DIR

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://download.visualstudio.microsoft.com/download/pr/c503e53c-0567-4604-b7a8-1d6e7a1357f5/53e78f56b01147a092c0cc273b443550/dotnet-sdk-$VERSION-osx-arm64.tar.gz"
	mkdir $VERSION
	mv "dotnet-sdk-$VERSION-osx-arm64.tar.gz" $VERSION/"dotnet-sdk-$VERSION-osx-arm64.tar.gz"
	cd $VERSION
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "dotnet-sdk-$VERSION-osx-arm64.tar.gz"

	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	printf "\t${bold}${green}Clearing${clear}\n"
	rm "dotnet-sdk-$VERSION-osx-arm64.tar.gz"
fi

cd $HOME/install-files