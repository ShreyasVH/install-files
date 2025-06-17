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

ERLANG_FOLDER_NAME=erlang
ERLANG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ERLANG_FOLDER_NAME" '.[$folder][$version][$name]')

ELIXIR_FOLDER_NAME=elixir
ELIXIR_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ELIXIR_FOLDER_NAME" '.[$folder][$version][$name]')

MAKE_FOLDER_NAME=make
MAKE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$MAKE_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/rabbitmq.conf ]; then
	printf "rabbitmq.conf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/rabbitmq-server" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$ERLANG_FOLDER_NAME/$ERLANG_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$ELIXIR_FOLDER_NAME/$ELIXIR_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$MAKE_FOLDER_NAME/$MAKE_VERSION/install.sh $((DEPTH+1))

	cd $HOME/programs/$FOLDER_NAME

	export PATH=$HOME/programs/$ERLANG_FOLDER_NAME/$ERLANG_VERSION/bin:$PATH
	export PATH=$HOME/programs/$ELIXIR_FOLDER_NAME/$ELIXIR_VERSION/bin:$PATH
	export PATH=$HOME/programs/$MAKE_FOLDER_NAME/$MAKE_VERSION/bin:$PATH

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE=rabbitmq-server-generic-unix-$VERSION.tar.xz
	wget -q "https://github.com/rabbitmq/rabbitmq-server/releases/download/v$VERSION/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "rabbitmq_server-$VERSION" $VERSION
	cd $VERSION

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	touch .envrc
	echo 'export RABBITMQ_HOME=$HOME/programs/'"$FOLDER_NAME/$VERSION" >> .envrc
	echo "" >> .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/sbin:"'$PATH' >> .envrc
	echo "" >> .envrc
	echo 'export PATH=$HOME/programs/'"$ERLANG_FOLDER_NAME/$ERLANG_VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	cp $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/rabbitmq.conf ./etc/rabbitmq/

	export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/sbin:$PATH

	print_message "${bold}${green}Enabling Management${clear}" $((DEPTH))
	rabbitmq-plugins enable rabbitmq_management > /dev/null 2>&1

	touch start.sh
	echo "PORT=\$(grep 'listeners.tcp.default = ' etc/rabbitmq/rabbitmq.conf | awk '{print \$3}')" >> start.sh
	echo '' >> start.sh
	echo 'if ! lsof -i :$PORT > /dev/null; then' >> start.sh
	echo -e '\techo "Starting"' >> start.sh
	echo -e "\trabbitmq-server -detached" >> start.sh
	echo -e '\twhile [[ ! $(lsof -i:$PORT -t | wc -l) -gt 0 ]]; do :; done' >> start.sh
	echo -e "\trabbitmqctl trace_on -p / > traceEnable.log 2>&1" >> start.sh
	echo 'fi' >> start.sh

	print_message "${bold}${green}Starting RMQ${clear}" $((DEPTH))
	bash start.sh

	touch stop.sh
	echo "PORT=\$(grep 'listeners.tcp.default = ' etc/rabbitmq/rabbitmq.conf | awk '{print \$3}')" >> stop.sh
	echo '' >> stop.sh
	echo 'if lsof -i :$PORT > /dev/null; then' >> stop.sh
	echo -e '\techo "Stopping"' >> stop.sh
	echo -e "\trabbitmqctl stop > stopLog.log 2>&1" >> stop.sh
	echo 'fi' >> stop.sh
	
	MANAGEMENT_PORT=$(grep 'management.tcp.port = ' etc/rabbitmq/rabbitmq.conf | awk '{print $3}')
	while [[ ! $(lsof -i:$MANAGEMENT_PORT -t | wc -l) -gt 0 ]]; do :; done
	wget -q "http://localhost:$MANAGEMENT_PORT/cli/rabbitmqadmin"
	chmod +x rabbitmqadmin
	mv rabbitmqadmin sbin/

	rabbitmqadmin -P $MANAGEMENT_PORT  declare queue name="trace" durable=true > /dev/null 2>&1
	rabbitmqadmin -P $MANAGEMENT_PORT declare binding source="amq.rabbitmq.trace" destination="trace" routing_key=# > /dev/null 2>&1

	print_message "${bold}${green}Stopping RMQ${clear}" $((DEPTH))
	bash stop.sh

	print_message "${bold}${green}Clearing${clear}" $((DEPTH))
	cd ..
	rm $ARCHIVE_FILE
fi

