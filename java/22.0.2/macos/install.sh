FOLDER_NAME=java
VERSION=22.0.2

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/java" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://github.com/bell-sw/Liberica/releases/download/$VERSION+11/bellsoft-jdk$VERSION+11-macos-aarch64.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "bellsoft-jdk$VERSION+11-macos-aarch64.tar.gz"
	mv "jdk-$VERSION.jdk" $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/java" ]; then
		cd $VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t${bold}${green}Clearing${clear}\n"
		cd ..
		rm "bellsoft-jdk$VERSION+11-macos-aarch64.tar.gz"
	fi
fi
