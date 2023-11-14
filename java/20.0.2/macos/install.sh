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

	printf "${bold}${yellow}Installing $FOLDER_NAME${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://download.oracle.com/java/$MAJOR_VERSION/archive/jdk-"$VERSION"_macos-aarch64_bin.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "jdk-"$VERSION"_macos-aarch64_bin.tar.gz"
	mv "jdk-$VERSION.jdk" $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/Contents/Home/bin/java" ]; then
		cd $VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/Contents/Home/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t${bold}${green}Clearing${clear}\n"
		cd ..
		rm "jdk-"$VERSION"_macos-aarch64_bin.tar.gz"
	fi
fi
