FOLDER_NAME=mongo
VERSION=5.0.25

cd $INSTALL_FILES_DIR

MONGO_SH_FOLDER_NAME=mongosh
MONGO_SH_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$MONGO_SH_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	bash $INSTALL_FILES_DIR/$MONGO_SH_FOLDER_NAME/$MONGO_SH_VERSION/macos/install.sh

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-$VERSION.tgz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "mongodb-macos-x86_64-$VERSION.tgz"
	mv "mongodb-macos-x86_64-$VERSION" $VERSION
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
		echo "mongod -f ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/mongod.conf --fork > mongo.log 2>&1 &" >> start.sh

		touch stop.sh
		PORT=$(grep 'port: ' ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/mongod.conf | awk '{print $2}')
		echo 'PORT=$(grep '\''port: '\'' ~/workspace/myProjects/config-samples/'$FOLDER_NAME'/'$VERSION'/macos/mongod.conf | awk '\''{print $2}'\'')' >> stop.sh
		echo 'kill -9 $(lsof -t -i:$PORT)' >> stop.sh

		printf "\t${bold}${green}Clearing${clear}\n"
		cd ..
		rm "mongodb-macos-x86_64-$VERSION.tgz"

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH
		cd $VERSION
		bash start.sh

		bash $INSTALL_FILES_DIR/$MONGO_SH_FOLDER_NAME/$MONGO_SH_VERSION/macos/install.sh

		printf "\t${bold}${green}Waiting for server start${clear}\n"
		while [[ ! $(lsof -i:$PORT -t | wc -l) -gt 0 ]];
		do
			:
		done

		export PATH=$HOME/programs/$MONGO_SH_FOLDER_NAME/$MONGO_SH_VERSION/bin:$PATH
		mongosh --eval 'rs.initiate({_id: "myReplicaSet", members: [{ _id: 0, host: "127.0.0.1:'$PORT'" }]})' "mongodb://127.0.0.1:$PORT" > rsInitiateLog.txt
	fi
fi

cd $HOME/install-files