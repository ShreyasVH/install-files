FOLDER_NAME=sbt
VERSION=0.13.18

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
	wget -q --show-progress "https://github.com/sbt/sbt/releases/download/v$VERSION/sbt-$VERSION.tgz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "sbt-$VERSION.tgz"
	mv sbt $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/sbt" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		cd ..
		printf "\t${bold}${green}Clearing${clear}\n"
		rm "sbt-$VERSION.tgz"
	fi
fi
