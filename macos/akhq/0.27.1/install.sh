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

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/application.yml ]; then
	printf "application.yml not found\n"
	exit
fi

BINARY_PATH=$(cat programData.json | jq -r --arg program $FOLDER_NAME '.[$program].path')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/$BINARY_PATH" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$JAVA_FOLDER_NAME/$JAVA_VERSION/install.sh $((DEPTH+1))

	cd $HOME/programs/$FOLDER_NAME
	mkdir ${VERSION}
	cd ${VERSION}

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="akhq-${VERSION}-all.jar"
	wget --show-progress "https://github.com/tchiotludo/akhq/releases/download/${VERSION}/${ARCHIVE_FILE}" > $HOME/logs/$FOLDER_NAME/$VERSION/download.txt 2>&1
	mv ${ARCHIVE_FILE} "akhq.jar"

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	touch .envrc
	echo "export PATH=\$HOME/programs/${JAVA_FOLDER_NAME}/${JAVA_VERSION}/bin:\$PATH" >> .envrc
	echo "export JAVA_HOME=\$HOME/programs/${JAVA_FOLDER_NAME}/${JAVA_VERSION}" >> .envrc
	direnv allow

	ln -s $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/application.yml .

	export JAVA_HOME=$HOME/programs/$JAVA_FOLDER_NAME/$JAVA_VERSION

	touch start.sh
	echo 'PIDFILE=akhq.pid' >> start.sh
	echo 'if [ ! -e "${PIDFILE}" ]; then' >> start.sh
	echo -e "\techo 'Starting'" >> start.sh
	echo -e '\tjava -Dmicronaut.config.files=application.yml -jar akhq.jar > server.log 2>&1 &' >> start.sh
	echo -e '\tpgrep -f 'akhq.jar' | tail -n 1 > "${PIDFILE}"' >> start.sh
	echo 'fi' >> start.sh

	touch stop.sh
	echo 'PIDFILE=akhq.pid' >> stop.sh
	echo 'if [ -e "${PIDFILE}" ]; then' >> stop.sh
	echo -e "\techo 'Stopping'" >> stop.sh
	echo -e '\tkill -9 $(cat ${PIDFILE})' >> stop.sh
	echo -e '\trm "${PIDFILE}"' >> stop.sh
	echo 'fi' >> stop.sh

	VERSION_STRING=$(echo "$VERSION" | sed 's/\./_/g')
	DOMAIN_NAME=akhq_$VERSION_STRING.local.com
	if ! grep -q "$DOMAIN_NAME" /etc/hosts; then
	    SUDO_ASKPASS=$HOME/askpass.sh sudo -A sh -c "echo '127.0.0.1 ' $DOMAIN_NAME >> /etc/hosts"
	fi
fi

