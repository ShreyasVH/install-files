FOLDER_NAME=redis
VERSION=7.0.14

cd $INSTALL_FILES_DIR

PKG_CONFIG_FOLDER_NAME=pkg-config
PKG_CONFIG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PKG_CONFIG_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/redis.conf ]; then
	printf "redis.conf not found\n"
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/sentinel.conf ]; then
	printf "sentinel.conf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/redis-server" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="$VERSION.tar.gz"
	wget -q --show-progress "https://github.com/redis/redis/archive/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "redis-$VERSION" $VERSION
	cd $VERSION
	sed -i '' 's/#ifdef __APPLE__/#ifdef __APPLE__\n#define _DARWIN_C_SOURCE/' src/config.h
	
	bash $INSTALL_FILES_DIR/make.sh $FOLDER_NAME $VERSION

	printf "\t${bold}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S -p '' PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/redis-server" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		touch start.sh
		mv $HOME/sources/$FOLDER_NAME/$VERSION/redis.conf ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/redis.conf.default
		mv $HOME/sources/$FOLDER_NAME/$VERSION/sentinel.conf ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/sentinel.conf.default
		echo "redis-server ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/redis.conf" >> start.sh
		echo "" >> start.sh
		echo "redis-sentinel ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/sentinel.conf" >> start.sh
		echo "" >> start.sh

		touch stop.sh
		echo 'PORT=$(grep '\''^port '\'' ~/workspace/myProjects/config-samples/'"$FOLDER_NAME/$VERSION"'/macos/redis.conf | awk '\''{print $2}'\'')' >> stop.sh
		echo 'SENTINEL_PORT=$(grep '\''^port '\'' ~/workspace/myProjects/config-samples/'"$FOLDER_NAME/$VERSION"'/macos/sentinel.conf | awk '\''{print $2}'\'')' >> stop.sh
		echo 'kill -9 $(lsof -i:$SENTINEL_PORT -t)' >> stop.sh
		echo 'redis-cli -p $PORT shutdown' >> stop.sh
		echo '' >> stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files