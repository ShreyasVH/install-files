FOLDER_NAME=java
VERSION=8.0.382

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u382-b05/openlogic-openjdk-8u382-b05-mac-x64.zip"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	unzip "openlogic-openjdk-8u382-b05-mac-x64.zip" > /dev/null 2>&1
	mv "openlogic-openjdk-8u382-b05-mac-x64/jdk1.8.0_382.jdk" $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/Contents/Home/bin/java" ]; then
		cd $VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/Contents/Home/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t${bold}${green}Clearing${clear}\n"
		cd ..
		rm -rf "openlogic-openjdk-8u382-b05-mac-x64"
		rm "openlogic-openjdk-8u382-b05-mac-x64.zip"
	fi
fi

cd $HOME/install-files