VERSION=3.11.21
FOLDER_NAME=rmq

cd $INSTALL_FILES_DIR

ERLANG_FOLDER_NAME=erlang
ERLANG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ERLANG_FOLDER_NAME" '.[$folder][$version][$name]')

ELIXIR_FOLDER_NAME=elixir
ELIXIR_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ELIXIR_FOLDER_NAME" '.[$folder][$version][$name]')

MAKE_FOLDER_NAME=make
MAKE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$MAKE_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/rabbitmq.conf ]; then
	printf "rabbitmq.conf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/rabbitmq-server" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	bash $INSTALL_FILES_DIR/$ERLANG_FOLDER_NAME/$ERLANG_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$ELIXIR_FOLDER_NAME/$ELIXIR_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$MAKE_FOLDER_NAME/$MAKE_VERSION/macos/install.sh

	cd $HOME/programs/$FOLDER_NAME

	export PATH=$HOME/programs/$ERLANG_FOLDER_NAME/$ERLANG_VERSION/bin:$PATH
	export PATH=$HOME/programs/$ELIXIR_FOLDER_NAME/$ELIXIR_VERSION/bin:$PATH
	export PATH=$HOME/programs/$MAKE_FOLDER_NAME/$MAKE_VERSION/bin:$PATH

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://github.com/rabbitmq/rabbitmq-server/releases/download/v$VERSION/rabbitmq-server-generic-unix-$VERSION.tar.xz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "rabbitmq-server-generic-unix-$VERSION.tar.xz"
	mv "rabbitmq_server-$VERSION" $VERSION
	cd $VERSION

	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	touch .envrc
	echo 'export RABBITMQ_HOME=$HOME/programs/'"$FOLDER_NAME/$VERSION" >> .envrc
	echo "" >> .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/sbin:"'$PATH' >> .envrc
	echo "" >> .envrc
	echo 'export PATH=$HOME/programs/'"$ERLANG_FOLDER_NAME/$ERLANG_VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	ln -s $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/rabbitmq.conf ./etc/rabbitmq/

	export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/sbin:$PATH

	printf "\t${bold}${green}Enabling Management${clear}\n"
	rabbitmq-plugins enable rabbitmq_management > /dev/null 2>&1

	touch start.sh
	echo "rabbitmq-server -detached" >> start.sh

	touch stop.sh
	echo "rabbitmqctl stop" >> stop.sh

	printf "\t${bold}${green}Clearing${clear}\n"
	cd ..
	rm "rabbitmq-server-generic-unix-$VERSION.tar.xz"
fi

