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
MAJOR_VERSION=$(echo $VERSION | cut -d '.' -f 1)
MINOR_VERSION=$(echo $VERSION | cut -d '.' -f 2)

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/my.cnf ]; then
	printf "my.cnf not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	LINK="$(get_protocol_for_binary "https")://$(get_domain_for_binary "cdn.mysql.com")/Downloads/MySQL-${MAJOR_VERSION}.${MINOR_VERSION}/mysql-${VERSION}-macos15-arm64.tar.gz"
	ARCHIVE_FILE="$(basename ${LINK})"
	start_time=$(date +%s)
	start_time_total=$(date +%s)
	download_binary "${FOLDER_NAME}" "${VERSION}" "${LINK}" "wget" "${DEPTH}"
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	tar -xf $ARCHIVE_FILE
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	mv mysql-$VERSION-macos15-arm64 $VERSION
	cd $VERSION

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	mkdir data
	ln -s $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/my.cnf $HOME/programs/$FOLDER_NAME/$VERSION/my.cnf

	touch start.sh
	echo "PORT=\$(grep -E '^ *port=' my.cnf | awk -F= '{print \$2}' | tr -d ' ')" >> start.sh
	echo '' >> start.sh
	echo 'if [ ! -e data/mysql.pid ]; then' >> start.sh
	echo -e '\techo "Starting"' >> start.sh
	echo -e "\tmysqld_safe --defaults-file=my.cnf > mysql.log 2>&1 &" >> start.sh
	echo 'fi' >> start.sh

	touch stop.sh
	VERSION_STRING=$(echo "$VERSION" | sed 's/\./_/g')
	echo "PORT=\$(grep -E '^ *port=' my.cnf | awk -F= '{print \$2}' | tr -d ' ')" >> stop.sh
	echo '' >> stop.sh
	echo 'if [ -e data/mysql.pid ]; then' >> stop.sh
	echo -e '\techo "Stopping"' >> stop.sh
	echo -e "\tmysqladmin --defaults-file=my.cnf -u shreyas -S data/mysql_$VERSION_STRING.sock --password=password shutdown > shutdown.log 2>&1 &" >> stop.sh
	echo -e '\trm data/mysql.pid' >> stop.sh
	echo 'fi' >> stop.sh

	print_message "${bold}${green}Initializing DB${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	mysqld --defaults-file=my.cnf --initialize 2> $HOME/logs/$FOLDER_NAME/$VERSION/initialize_db.log
	TEMP_PASSWORD=$(grep -e 'A temporary password is generated for root@localhost: ' $HOME/logs/$FOLDER_NAME/$VERSION/initialize_db.log | awk '{print $13}')
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	print_message "${bold}${green}Initial run${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	mysqld_safe --defaults-file=my.cnf --skip-grant-tables > $HOME/logs/$FOLDER_NAME/$VERSION/initializeStart.txt 2>&1 &
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	PORT=$(grep -E '^ *port=' my.cnf | awk -F= '{print $2}' | tr -d ' ')

	print_message "${bold}${green}Sleeping for 60s${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	sleep 60
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	print_message "${bold}${green}Creating user${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	mysql -u root -S "data/mysql_$VERSION_STRING.sock" -P $PORT <<EOF
FLUSH PRIVILEGES;
CREATE USER '$MYSQL_USERNAME'@'%' IDENTIFIED with caching_sha2_password BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USERNAME'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	print_message "${bold}${green}Stopping${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	mysqladmin --defaults-file=my.cnf -u $MYSQL_USERNAME --password=$MYSQL_PASSWORD -S data/mysql_${VERSION_STRING}.sock shutdown > shutdown.log 2>&1 &
	rm -rf data/mysql.pid
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	bash $INSTALL_FILES_DIR/clearBinary.sh $ARCHIVE_FILE $((DEPTH))

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi

