FOLDER_NAME=cmake
VERSION=3.19.2

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/logs" ]; then
	mkdir "$HOME/logs"
fi

if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
	mkdir "$HOME/sources/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME${clear}\n"

	printf "\t${bold}${blink}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://github.com/Kitware/CMake/releases/download/v$VERSION/cmake-$VERSION.tar.gz"
	printf "\t${bold}${blink}${green}Extracting source code${clear}\n"
	tar -xf "cmake-$VERSION.tar.gz"
	mv "cmake-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${blink}${green}Bootstrapping${clear}\n"
	./bootstrap --help > $HOME/logs/$FOLDER_NAME/$VERSION/bootstrapHelp.txt 2>&1
	./bootstrap --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/bootstrapOutput.txt 2>&1
	printf "\t${bold}${blink}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${blink}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/cmake" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t${bold}${blink}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "cmake-$VERSION.tar.gz"
	fi
fi

cd $HOME/install-files