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

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/docker-compose.yml ]; then
	print_message "${red}${bold}docker-compose.yml not found${clear}"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/start.sh" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0
	mkdir $HOME/programs/$FOLDER_NAME/$VERSION

	cd $HOME/programs/$FOLDER_NAME/$VERSION

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	cp $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/docker-compose.yml docker-compose.yml

	print_message "${bold}${green}Building image${clear}"
	docker compose -f docker-compose.yml build > compile.log 2>&1

	touch start.sh
	echo "docker compose -p $FOLDER_NAME -f docker-compose.yml up -d > server.log 2>&1" >> start.sh

	touch stop.sh
	echo "docker compose -p $FOLDER_NAME -f docker-compose.yml stop > shutdown.log 2>&1" >> stop.sh
fi