version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)

program_dir=$(dirname "$version_dir")
FOLDER_NAME=$(basename $program_dir)

os_dir=$(dirname $program_dir)
OS=$(basename $os_dir)

DEPTH=1
if [ $# -ge 1 ]; then
    DEPTH=$1
fi

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

PKG_CONFIG_FOLDER_NAME=pkg-config
PKG_CONFIG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PKG_CONFIG_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/redis.conf ]; then
	printf "redis.conf not found\n"
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/sentinel.conf ]; then
	printf "sentinel.conf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/redis-server" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="$VERSION.tar.gz"
	wget -q "https://github.com/redis/redis/archive/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "redis-$VERSION" $VERSION
	cd $VERSION
	sed -i '' 's/#ifdef __APPLE__/#ifdef __APPLE__\n#define _DARWIN_C_SOURCE/' src/config.h
	
	bash $INSTALL_FILES_DIR/make.sh $FOLDER_NAME $VERSION $((DEPTH))

	print_message "${bold}${green}Installing${clear}" $((DEPTH))
	echo $USER_PASSWORD | sudo -S -p '' PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/redis-server" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		touch start.sh
		mv $HOME/sources/$FOLDER_NAME/$VERSION/redis.conf ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/redis.conf.default
		mv $HOME/sources/$FOLDER_NAME/$VERSION/sentinel.conf ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/sentinel.conf.default
		cp $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/redis.conf ./
		cp $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/sentinel.conf ./
		echo 'PORT=$(grep '\''^port '\'' redis.conf | awk '\''{print $2}'\'')' >> start.sh
		echo '' >> start.sh
		echo 'if ! lsof -i :$PORT > /dev/null; then' >> start.sh
		echo -e '\techo "Starting"' >> start.sh
		echo -e "\tredis-server redis.conf" >> start.sh
		echo 'fi' >> start.sh
		echo '' >> start.sh
		echo 'SENTINEL_PORT=$(grep '\''^port '\'' sentinel.conf | awk '\''{print $2}'\'')' >> start.sh
		echo 'if ! lsof -i :$SENTINEL_PORT > /dev/null; then' >> start.sh
		echo -e '\techo "Starting sentinel"' >> start.sh
		echo -e "\tredis-sentinel sentinel.conf" >> start.sh
		echo 'fi' >> start.sh

		touch stop.sh
		echo 'SENTINEL_PORT=$(grep '\''^port '\'' sentinel.conf | awk '\''{print $2}'\'')' >> stop.sh
		echo '' >> stop.sh
		echo 'if lsof -i :$SENTINEL_PORT > /dev/null; then' >> stop.sh
		echo -e '\techo "Stopping sentinel"' >> stop.sh
		echo -e '\tkill -9 $(lsof -i:$SENTINEL_PORT -t)' >> stop.sh
		echo 'fi' >> stop.sh
		echo '' >> stop.sh
		echo 'PORT=$(grep '\''^port '\'' redis.conf | awk '\''{print $2}'\'')' >> stop.sh
		echo '' >> stop.sh
		echo 'if lsof -i :$PORT > /dev/null; then' >> stop.sh
		echo -e '\techo "Stopping"' >> stop.sh
		echo -e '\tredis-cli -p $PORT shutdown' >> stop.sh
		echo 'fi' >> stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi

