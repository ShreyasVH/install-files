version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)

program_dir=$(dirname "$version_dir")
FOLDER_NAME=$(basename $program_dir)

os_dir=$(dirname $program_dir)
OS=$(basename $os_dir)

DEPTH=1
if [ $# -ge 1 ]; then
    DEPTH=$1
fi

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

MONGO_SH_FOLDER_NAME=mongosh
MONGO_SH_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$MONGO_SH_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/mongod.conf ]; then
	printf "mongod.conf not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE=mongodb-macos-arm64-$VERSION.tgz
	wget -q "https://fastdl.mongodb.org/osx/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
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

		ln -s $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/mongod.conf mongod.conf
		touch start.sh
		echo 'PORT=$(grep '\''port: '\'' mongod.conf | awk '\''{print $2}'\'')' >> start.sh
		echo '' >> start.sh
		echo 'if [ ! -e mongod.pid ]; then' >> start.sh
		echo -e '\techo "Starting"' >> start.sh
		echo -e "\tmongod -f mongod.conf > mongo.log 2>&1 &" >> start.sh
		echo 'fi' >> start.sh

		touch stop.sh
		PORT=$(grep 'port: ' mongod.conf | awk '{print $2}')
		echo 'PORT=$(grep '\''port: '\'' mongod.conf | awk '\''{print $2}'\'')' >> stop.sh
		echo '' >> stop.sh
		echo 'if [ -e mongod.pid ]; then' >> stop.sh
		echo -e '\techo "Stopping"' >> stop.sh
		echo -e '\tkill -9 $(cat mongod.pid)' >> stop.sh
		echo -e '\trm mongod.pid' >> stop.sh
		echo 'fi' >> stop.sh

		print_message "${bold}${green}Clearing${clear}" $((DEPTH))
		cd ..
		rm $ARCHIVE_FILE

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH
		cd $VERSION
		bash start.sh > /dev/null 2>&1

		bash $INSTALL_FILES_DIR/$OS/$MONGO_SH_FOLDER_NAME/$MONGO_SH_VERSION/install.sh  $((DEPTH+1))

		printf "\t${bold}${green}Waiting for server start${clear}\n"
		while [[ ! $(lsof -i:$PORT -t | wc -l) -gt 0 ]];
		do
			:
		done

		export PATH=$HOME/programs/$MONGO_SH_FOLDER_NAME/$MONGO_SH_VERSION/bin:$PATH
		mongosh --eval 'rs.initiate({_id: "myReplicaSet", members: [{ _id: 0, host: "127.0.0.1:'$PORT'" }]})' "mongodb://127.0.0.1:$PORT" > rsInitiateLog.txt
		bash stop.sh > /dev/null 2>&1
	fi
fi

