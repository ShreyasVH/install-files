FOLDER_NAME=mongo
VERSION=6.0.6

MONGO_SH_FOLDER_NAME=mongosh
MONGO_SH_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$MONGO_SH_FOLDER_NAME" '.[$folder][$version][$name]')

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/wsl_20_04/mongod.conf ]; then
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
	ARCHIVE_FILE=mongodb-linux-x86_64-ubuntu2004-$VERSION.tgz
	wget -q --show-progress "https://fastdl.mongodb.org/linux/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "mongodb-linux-x86_64-ubuntu2004-$VERSION" $VERSION
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
		echo "mongod -f ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/wsl_20_04/mongod.conf --fork > mongo.log 2>&1 &" >> start.sh

		touch stop.sh
		PORT=$(grep 'port: ' ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/wsl_20_04/mongod.conf | awk '{print $2}')
		echo 'PORT=$(grep '\''port: '\'' ~/workspace/myProjects/config-samples/'$FOLDER_NAME'/'$VERSION'/wsl_20_04/mongod.conf | awk '\''{print $2}'\'')' >> stop.sh
		echo 'kill -9 $(lsof -t -i:$PORT)' >> stop.sh

		printf "\t${bold}${green}Clearing${clear}\n"
		cd ..
		rm $ARCHIVE_FILE

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH
		cd $VERSION
		bash start.sh

		bash $INSTALL_FILES_DIR/$MONGO_SH_FOLDER_NAME/$MONGO_SH_VERSION/wsl_20_04/install.sh

		echo 'Sleeping for 60s'
		sleep 60

		export PATH=$HOME/programs/$MONGO_SH_FOLDER_NAME/$MONGO_SH_VERSION/bin:$PATH
		mongosh --eval 'rs.initiate({_id: "myReplicaSet", members: [{ _id: 0, host: "127.0.0.1:'$PORT'" }]})' "mongodb://127.0.0.1:$PORT"
	fi
fi

cd $HOME/install-files