VERSION=1.6.26
FOLDER_NAME=memcached

cd $INSTALL_FILES_DIR

LIBEVENT_FOLDER_NAME=libevent
LIBEVENT_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBEVENT_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/memcached" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$LIBEVENT_FOLDER_NAME/$LIBEVENT_VERSION/macos/install.sh

	cd "$HOME/sources/$FOLDER_NAME"

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="memcached-$VERSION.tar.gz"
	wget -q --show-progress "https://memcached.org/files/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "memcached-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-libevent=$HOME/programs/$LIBEVENT_FOLDER_NAME/$LIBEVENT_VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/memcached" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		sudo chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		PORT=1320

		touch start.sh
		echo "memcached -p $PORT -d > memcached.log 2>&1 &" >> start.sh

		touch stop.sh
		echo 'kill -9 $(lsof -t -i:'$PORT')' >> stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi