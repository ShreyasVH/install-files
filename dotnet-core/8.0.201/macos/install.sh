FOLDER_NAME=dotnet-core
VERSION=8.0.201

cd $INSTALL_FILES_DIR

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://download.visualstudio.microsoft.com/download/pr/d89ef89a-8e7e-4e04-b32a-8eb6d32a4409/ff889260b90ff66ec8818dd5619de64c/dotnet-sdk-$VERSION-osx-arm64.tar.gz"

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