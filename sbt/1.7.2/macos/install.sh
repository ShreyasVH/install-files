FOLDER_NAME=sbt
VERSION=1.7.2

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

	cd $VERSION
	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	cd ..
	rm "sbt-$VERSION.tgz"
fi
