FOLDER_NAME=java
VERSION=11.0.19

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/java" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://builds.openlogic.com/downloadJDK/openlogic-openjdk-jre/$VERSION+7/openlogic-openjdk-jre-$VERSION+7-linux-x64.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "openlogic-openjdk-jre-$VERSION+7-linux-x64.tar.gz"
	mv "openlogic-openjdk-jre-$VERSION+7-linux-x64" $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/java" ]; then
		cd $VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t${bold}${green}Clearing${clear}\n"
		cd ..
		rm "openlogic-openjdk-jre-$VERSION+7-linux-x64.tar.gz"
	fi
fi

