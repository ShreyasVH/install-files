VERSION=5.24.2
FOLDER_NAME=neo4j

cd $INSTALL_FILES_DIR

JAVA_FOLDER_NAME=java
JAVA_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$JAVA_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/neo4j.conf ]; then
	printf "neo4j.conf not found\n"
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/neo4j-admin.conf ]; then
	printf "neo4j-admin.conf not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	bash $INSTALL_FILES_DIR/$JAVA_FOLDER_NAME/$JAVA_VERSION/macos/install.sh

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://dist.neo4j.org/neo4j-community-$VERSION-unix.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "neo4j-community-$VERSION-unix.tar.gz"
	mv "neo4j-community-$VERSION" $VERSION
	cd $VERSION

	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$JAVA_FOLDER_NAME/$JAVA_VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	echo 'export JAVA_HOME=$HOME/programs/'"$JAVA_FOLDER_NAME/$JAVA_VERSION" >> .envrc
	echo "" >> .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	mv conf/neo4j.conf $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/neo4j.conf.default
	ln -s $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/neo4j.conf conf/neo4j.conf
	mv conf/neo4j-admin.conf $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/neo4j-admin.conf.default
	ln -s $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/neo4j-admin.conf conf/neo4j-admin.conf

	touch start.sh
	echo "neo4j start > neo4j_start.log 2>&1 &" >> start.sh

	touch stop.sh
	echo "neo4j stop > neo4j_stop.log 2>&1 &" >> stop.sh

	VERSION_STRING=$(echo "$VERSION" | sed 's/\./_/g')
	DOMAIN_NAME=neo4j_$VERSION_STRING.local.com
	if ! grep -q "$DOMAIN_NAME" /etc/hosts; then
	    echo $USER_PASSWORD | sudo -S -p '' sh -c "echo '127.0.0.1 ' $DOMAIN_NAME >> /etc/hosts"
	fi

	printf "\t${bold}${green}Clearing${clear}\n"
	cd ..
	rm "neo4j-community-$VERSION-unix.tar.gz"
fi
