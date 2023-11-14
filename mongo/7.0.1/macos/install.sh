FOLDER_NAME=mongo
VERSION=7.0.1

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/mongod.conf ]; then
	printf "mongod.conf not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://fastdl.mongodb.org/osx/mongodb-macos-arm64-$VERSION.tgz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "mongodb-macos-arm64-$VERSION.tgz"
	mv "mongodb-macos-aarch64-$VERSION" $VERSION
	cd $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mongod" ]; then
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		mkdir data
		mkdir logs

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		touch start.sh
		echo "mongod -f ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/mongod.conf --fork --replSet myReplicaSet > mongo.log 2>&1 &" >> start.sh

		touch stop.sh
		echo 'PORT=$(grep '\''port: '\'' ~/workspace/myProjects/config-samples/'$FOLDER_NAME'/'$VERSION'/macos/mongod.conf | awk '\''{print $2}'\'')' >> stop.sh
		echo 'kill -9 $(lsof -t -i:$PORT)' >> stop.sh


		printf "\t${bold}${green}Clearing${clear}\n"
		cd ..
		rm "mongodb-macos-arm64-$VERSION.tgz"
	fi
fi

cd $HOME/install-files