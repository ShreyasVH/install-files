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

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/neo4j.conf ]; then
	printf "neo4j.conf not found\n"
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/neo4j-admin.conf ]; then
	printf "neo4j-admin.conf not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$JAVA_FOLDER_NAME/$JAVA_VERSION/install.sh $((DEPTH+1))

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE=neo4j-community-$VERSION-unix.tar.gz
	wget --show-progress "https://dist.neo4j.org/$ARCHIVE_FILE" > $HOME/logs/$FOLDER_NAME/$VERSION/download.txt 2>&1
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "neo4j-community-$VERSION" $VERSION
	cd $VERSION

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$JAVA_FOLDER_NAME/$JAVA_VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	echo 'export JAVA_HOME=$HOME/programs/'"$JAVA_FOLDER_NAME/$JAVA_VERSION" >> .envrc
	echo "" >> .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	mv conf/neo4j.conf $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/neo4j.conf.default
	ln -s $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/neo4j.conf conf/neo4j.conf
	mv conf/neo4j-admin.conf $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/neo4j-admin.conf.default
	ln -s $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/neo4j-admin.conf conf/neo4j-admin.conf

	touch start.sh
	echo "neo4j start > neo4j_start.log 2>&1 &" >> start.sh

	touch stop.sh
	echo "neo4j stop > neo4j_stop.log 2>&1 &" >> stop.sh

	VERSION_STRING=$(echo "$VERSION" | sed 's/\./_/g')
	DOMAIN_NAME=neo4j_$VERSION_STRING.local.com
	if ! grep -q "$DOMAIN_NAME" /etc/hosts; then
	    SUDO_ASKPASS=$HOME/askpass.sh sudo -A sh -c "echo '127.0.0.1 '$DOMAIN_NAME >> /etc/hosts"
	fi

	print_message "${bold}${green}Clearing${clear}" $((DEPTH))
	cd ..
	rm $ARCHIVE_FILE
fi
