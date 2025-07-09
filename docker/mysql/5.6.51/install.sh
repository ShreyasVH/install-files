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

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/my.cnf ]; then
	print_message "${red}${bold}my.cnf not found${clear}"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/start.sh" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0
	mkdir $HOME/programs/$FOLDER_NAME/$VERSION

	cd $HOME/programs/$FOLDER_NAME/$VERSION

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	cp $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/docker-compose.yml docker-compose.yml
	cp $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/my.cnf my.cnf

	print_message "${bold}${green}Building image${clear}" $((DEPTH))
	docker compose -f docker-compose.yml build > /dev/null 2>&1

	touch start.sh
	echo "PORT=\$(grep -E '^ *port=' my.cnf | awk -F= '{print \$2}' | tr -d ' ')" >> start.sh
	echo '' >> start.sh
	echo 'if ! lsof -i :$PORT > /dev/null; then' >> start.sh
	echo -e '\techo "Starting"' >> start.sh
	echo -e "\tdocker compose -p mysql -f docker-compose.yml up -d > /dev/null 2>&1" >> start.sh
	echo 'fi' >> start.sh

	touch stop.sh
	echo "PORT=\$(grep -E '^ *port=' my.cnf | awk -F= '{print \$2}' | tr -d ' ')" >> stop.sh
	echo '' >> stop.sh
	echo 'if lsof -i :$PORT > /dev/null; then' >> stop.sh
	echo -e '\techo "Stopping"' >> stop.sh
	echo -e "\tdocker compose -p mysql -f docker-compose.yml stop > /dev/null 2>&1" >> stop.sh
	echo 'fi' >> stop.sh

	bash start.sh > /dev/null 2>&1
	MYSQL_PORT=$(grep -E '^ *port=' my.cnf | awk -F= '{print $2}' | tr -d ' ')
	print_message "Waiting for mysql to start" $((DEPTH))
	until docker exec $VERSION mysqladmin ping -u root -P $MYSQL_PORT -p"$MYSQL_PASSWORD" --silent > /dev/null 2>&1; do
	    printf "."
	    sleep 2
	done
	printf "\n"

	print_message "Granting privileges" $((DEPTH))
	docker exec -i $VERSION mysql -u root -P $MYSQL_PORT -p"$MYSQL_PASSWORD"<<EOF
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USERNAME'@'%';
FLUSH PRIVILEGES;
EOF

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	bash stop.sh > /dev/null 2>&1

fi