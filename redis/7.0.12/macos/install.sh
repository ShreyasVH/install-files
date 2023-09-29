FOLDER_NAME=redis
VERSION=7.0.12

PKG_CONFIG_FOLDER_NAME=pkg-config
PKG_CONFIG_VERSION=0.29.2

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
	mkdir "$HOME/sources/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	bash $INSTALL_FILES_DIR/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH

	wget "https://github.com/redis/redis/archive/$VERSION.tar.gz"
	tar -xvf "$VERSION.tar.gz"
	mv "redis-$VERSION" $VERSION
	cd $VERSION
	make
	sudo PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	touch start.sh
	echo "redis-server ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/redis.conf" >> start.sh
	echo "" >> start.sh
	echo "redis-sentinel ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/sentinel.conf" >> start.sh
	echo "" >> start.sh

	touch stop.sh
	echo 'PORT=$(grep '\''^port '\'' ~/workspace/myProjects/config-samples/'"$FOLDER_NAME/$VERSION"'/macos/redis.conf | awk '\''{print $2}'\'')' >> stop.sh
	echo 'SENTINEL_PORT=$(grep '\''^port '\'' ~/workspace/myProjects/config-samples/'"$FOLDER_NAME/$VERSION"'/macos/sentinel.conf | awk '\''{print $2}'\'')' >> stop.sh
	echo 'kill -9 $SENTINEL_PORT' >> stop.sh
	echo 'redis-cli -p $PORT shutdown' >> stop.sh
	echo '' >> stop.sh

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "$VERSION.tar.gz"
fi

cd $HOME/install-files