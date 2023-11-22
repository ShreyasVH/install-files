FOLDER_NAME=java
VERSION=20.0.2
MAJOR_VERSION=20

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
	wget -q --show-progress "https://github.com/bell-sw/Liberica/releases/download/$VERSION+10/bellsoft-jdk$VERSION+10-macos-aarch64.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "bellsoft-jdk$VERSION+10-macos-aarch64.tar.gz"
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
		rm "bellsoft-jdk$VERSION+10-macos-aarch64.tar.gz"
	fi
fi
