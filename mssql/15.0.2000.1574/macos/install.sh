FOLDER_NAME=mssql
VERSION=15.0.2000.1574

cd $INSTALL_FILES_DIR

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/docker-compose.yml ]; then
	printf "docker-compose.yml not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/start.sh" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0
	mkdir $HOME/programs/$FOLDER_NAME/$VERSION

	cd $HOME/programs/$FOLDER_NAME/$VERSION

	touch start.sh
	echo "docker compose -p mssql -f ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/docker-compose.yml up -d > /dev/null 2>&1" >> start.sh

	touch stop.sh
	echo "docker compose -p mssql -f ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/docker-compose.yml stop > /dev/null 2>&1" > stop.sh
fi

cd $HOME/install-files