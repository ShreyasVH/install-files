FOLDER_NAME=haproxy
VERSION=2.9.7
MINOR_VERSION=2.9

cd $INSTALL_FILES_DIR

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/haproxy.cfg ]; then
	printf "haproxy.cfg not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/haproxy" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="haproxy-$VERSION.tar.gz"
	wget -q --show-progress "https://www.haproxy.org/download/$MINOR_VERSION/src/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "haproxy-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Making${clear}\n"
	make PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION TARGET=osx USE_OPENSSL=1 SSL_INC=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/include SSL_LIB=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S -p '' make install PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/haproxy" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/sbin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		touch start.sh
		echo "echo $USER_PASSWORD | sudo -S -p '' haproxy -f ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/haproxy.cfg -D" >> start.sh

		touch stop.sh
		echo 'echo '$USER_PASSWORD' | sudo -S -p "" kill -9 $(echo '$USER_PASSWORD' | sudo -S -p "" lsof -t -i:80)' >> stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi
