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

JAVA_FOLDER_NAME=java
JAVA_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$JAVA_FOLDER_NAME" '.[$folder][$version][$name]')

SCALA_VERSION=$(cat "${STATIC_VERSION_MAP_PATH}" | jq -r --arg folder "${FOLDER_NAME}" --arg version "${VERSION}" '.[$folder][$version].scala')

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/server.properties ]; then
	printf "server.properties not found\n"
	exit
fi

BINARY_PATH=$(cat programData.json | jq -r --arg program $FOLDER_NAME '.[$program].path')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/$BINARY_PATH" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$JAVA_FOLDER_NAME/$JAVA_VERSION/install.sh $((DEPTH+1))

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="kafka_${SCALA_VERSION}-${VERSION}.tgz"
	wget --show-progress "https://dlcdn.apache.org/kafka/${VERSION}/${ARCHIVE_FILE}" > $HOME/logs/$FOLDER_NAME/$VERSION/download.txt 2>&1
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "kafka_${SCALA_VERSION}-${VERSION}" $VERSION
	cd $VERSION

	mkdir kraft-combined-logs

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	touch .envrc
	echo "export JAVA_HOME=\$HOME/programs/${JAVA_FOLDER_NAME}/${JAVA_VERSION}" >> .envrc
	direnv allow

	mv config/server.properties $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/server.properties.default
	ln -s $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/server.properties ./config

	export JAVA_HOME=$HOME/programs/$JAVA_FOLDER_NAME/$JAVA_VERSION

	print_message "${bold}${green}Generating uuid${clear}" $((DEPTH))
	KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"

	print_message "${bold}${green}Updating properties${clear}" $((DEPTH))
	bin/kafka-storage.sh format --standalone -t ${KAFKA_CLUSTER_ID} -c config/server.properties > $HOME/logs/$FOLDER_NAME/$VERSION/update.txt 2>&1

	touch start.sh
	echo 'PIDFILE=kafka.pid' >> start.sh
	echo 'if [ ! -e "${PIDFILE}" ]; then' >> start.sh
	echo -e "\techo 'Starting'" >> start.sh
	echo -e '\tbin/kafka-server-start.sh -daemon config/server.properties' >> start.sh
	echo -e '\tpgrep -f 'kafka.Kafka' | tail -n 1 > "${PIDFILE}"' >> start.sh
	echo 'fi' >> start.sh

	touch stop.sh
	echo 'PIDFILE=kafka.pid' >> stop.sh
	echo 'if [ -e "${PIDFILE}" ]; then' >> stop.sh
	echo -e "\techo 'Stopping'" >> stop.sh
	echo -e '\tbin/kafka-server-stop.sh' >> stop.sh
	echo -e '\trm "${PIDFILE}"' >> stop.sh
	echo 'fi' >> stop.sh

	print_message "${bold}${green}Clearing${clear}" $((DEPTH))
	cd ..
	rm $ARCHIVE_FILE
fi

