FOLDER_NAME=redis
VERSION=7.0.13

PKG_CONFIG_FOLDER_NAME=pkg-config
PKG_CONFIG_VERSION=0.29.2

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/logs" ]; then
	mkdir "$HOME/logs"
fi

if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
	mkdir "$HOME/sources/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION"
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/redis.conf ]; then
	printf "redis.conf not found\n"
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/sentinel.conf ]; then
	printf "sentinel.conf not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	bash $INSTALL_FILES_DIR/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH

	printf "${bold}${yellow}Installing $FOLDER_NAME${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://github.com/redis/redis/archive/$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "$VERSION.tar.gz"
	mv "redis-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Making${clear}\n"
	sed -i '' 's/#ifdef __APPLE__/#ifdef __APPLE__\n#define _DARWIN_C_SOURCE/' src/config.h
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
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

		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "$VERSION.tar.gz"
	fi
fi

cd $HOME/install-files