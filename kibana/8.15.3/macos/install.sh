FOLDER_NAME=kibana
VERSION=8.15.3

cd $INSTALL_FILES_DIR

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/kibana.yml ]; then
	printf "kibana.yml not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/kibana" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0
	
	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://artifacts.elastic.co/downloads/kibana/kibana-$VERSION-darwin-x86_64.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "kibana-$VERSION-darwin-x86_64.tar.gz"
	mv "kibana-$VERSION" $VERSION
	cd $VERSION

	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	touch start.sh
	echo "kibana serve > kibana.log 2>&1 &" >> start.sh

	touch stop.sh
	mv config/kibana.yml ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/kibana.yml.default
	ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/kibana.yml config/kibana.yml
	echo 'PORT=$(grep '\''server.port: '\'' config/kibana.yml | awk '\''{print $2}'\'')' >> stop.sh
	echo 'kill -9 $(lsof -t -i:$PORT)' >> stop.sh

	printf "\t${bold}${green}Clearing${clear}\n"
	cd ..
	rm "kibana-$VERSION-darwin-x86_64.tar.gz"
fi

cd $HOME/install-files