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
MONGO_SH_VERSION=$(jq -r --arg folder "${MONGO_SH_FOLDER_NAME}" '.[$folder]' latestVersions.json)

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/mongod.conf ]; then
	printf "mongod.conf not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	LINK="$(get_protocol_for_binary "https")://$(get_domain_for_binary "fastdl.mongodb.org")/osx/mongodb-macos-arm64-$VERSION.tgz"
	ARCHIVE_FILE="$(basename ${LINK})"
	start_time=$(date +%s)
	start_time_total=$(date +%s)
	download_binary "${FOLDER_NAME}" "${VERSION}" "${LINK}" "wget" "${DEPTH}"
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	tar -xf $ARCHIVE_FILE
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	mv "mongodb-macos-aarch64--$VERSION" $VERSION
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

		bash $INSTALL_FILES_DIR/clearBinary.sh $ARCHIVE_FILE $((DEPTH))

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH
		cd $VERSION
		bash start.sh > /dev/null 2>&1

		bash $INSTALL_FILES_DIR/$OS/$MONGO_SH_FOLDER_NAME/$MONGO_SH_VERSION/install.sh  $((DEPTH+1))

		print_message "${bold}${green}Waiting for server start${clear}" $((DEPTH))
		while [[ ! $(lsof -i:$PORT -t | wc -l) -gt 0 ]];
		do
			:
		done

		export PATH=$HOME/programs/$MONGO_SH_FOLDER_NAME/$MONGO_SH_VERSION/bin:$PATH
		mongosh --eval 'rs.initiate({_id: "myReplicaSet", members: [{ _id: 0, host: "mongo.local.com:'$PORT'" }]})' "mongodb://127.0.0.1:$PORT" > rsInitiateLog.txt
		bash stop.sh > /dev/null 2>&1
	fi
fi

