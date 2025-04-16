FOLDER_NAME=elasticsearch
VERSION=8.15.0

cd $INSTALL_FILES_DIR

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/elasticsearch.yml ]; then
	printf "elasticsearch.yml not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/elasticsearch" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE=elasticsearch-$VERSION-darwin-aarch64.tar.gz
	wget -q --show-progress "https://artifacts.elastic.co/downloads/elasticsearch/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "elasticsearch-$VERSION" $VERSION
	cd $VERSION

	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	touch start.sh
	echo "elasticsearch -d > elastic.log 2>&1 &" >> start.sh

	touch stop.sh
	mv config/elasticsearch.yml ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/elasticsearch.yml.default
	ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/elasticsearch.yml config/elasticsearch.yml
	echo 'PORT=$(grep '\''http.port: '\'' config/elasticsearch.yml | awk '\''{print $2}'\'')' >> stop.sh
	echo 'kill -9 $(lsof -t -i:$PORT)' >> stop.sh

	printf "\t${bold}${green}Clearing${clear}\n"
	cd ..
	rm $ARCHIVE_FILE
fi

cd $HOME/install-files