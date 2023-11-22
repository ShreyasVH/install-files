FOLDER_NAME=elasticsearch
VERSION=5.6.16

JAVA_FOLDER_NAME=java
JAVA_VERSION=8.0.382

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/elasticsearch.yml ]; then
	printf "elasticsearch.yml not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/$JAVA_FOLDER_NAME/$JAVA_VERSION/macos/install.sh

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	# wget -q --show-progress "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$VERSION-darwin-x86_64.tar.gz"
	wget -q --show-progress "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "elasticsearch-$VERSION.tar.gz"
	mv "elasticsearch-$VERSION" $VERSION
	cd $VERSION

	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	echo 'export PATH=$HOME/programs/'$JAVA_FOLDER_NAME'/'$JAVA_VERSION'/Contents/Home/bin:$PATH' >> .envrc
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
	rm "elasticsearch-$VERSION.tar.gz"
fi

cd $HOME/install-files