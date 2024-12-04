FOLDER_NAME=mongosh
VERSION=2.2.15

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
	ARCHIEVE_FILE="mongosh-$VERSION-linux-x64.tgz"
	wget -q --show-progress "https://downloads.mongodb.com/compass/$ARCHIEVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIEVE_FILE
	mv "mongosh-$VERSION-linux-x64" $VERSION
	cd $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mongosh" ]; then
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t${bold}${green}Clearing${clear}\n"
		cd ..
		rm $ARCHIEVE_FILE
	fi
fi

cd $HOME/install-files