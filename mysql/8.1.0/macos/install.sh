FOLDER_NAME=mysql
VERSION=8.1.0
MINOR_VERSION=8.1

cd $INSTALL_FILES_DIR

CMAKE_FOLDER_NAME=cmake
CMAKE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$CMAKE_FOLDER_NAME" '.[$folder][$version][$name]')

BOOST_FOLDER_NAME=boost

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

BISON_FOLDER_NAME=bison
BISON_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$BISON_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/my.cnf ]; then
	printf "my.cnf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mysql" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$BISON_FOLDER_NAME/$BISON_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/bin:$PATH

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"
	
	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="mysql-$VERSION.tar.gz"
	wget -q --show-progress "https://dev.mysql.com/get/Downloads/MySQL-$MINOR_VERSION/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "mysql-"$VERSION $VERSION
	cd $VERSION
	mkdir bld
	cd bld
	printf "\t${bold}${green}Configuring${clear}\n"
	cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=$HOME/programs/$BOOST_FOLDER_NAME -DCMAKE_INSTALL_PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION -DOPENSSL_ROOT_DIR=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION -DBISON_EXECUTABLE=$HOME/programs/$BISON_FOLDER_NAME/$BISON_VERSION/bin/bison > $HOME/logs/$FOLDER_NAME/$VERSION/cmakeOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mysql" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH
		export PATH=$HOME/programs/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/bin:$PATH
		export PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/bin:$PATH

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		mkdir data
		ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/my.cnf ./

		touch start.sh
		echo "mysqld_safe --defaults-file=my.cnf > mysql.log 2>&1 &" >> start.sh

		touch stop.sh
		VERSION_STRING=$(echo "$VERSION" | sed 's/\./_/g')
		echo "mysqladmin --defaults-file=my.cnf -u shreyas -S data/mysql_$VERSION_STRING.sock --password=password shutdown" >> stop.sh

		printf "\t${bold}${green}Initializing DB${clear}\n"
		mysqld --defaults-file=my.cnf --initialize 2> $HOME/logs/$FOLDER_NAME/$VERSION/initialize_db.log
		TEMP_PASSWORD=$(grep -e 'A temporary password is generated for root@localhost: ' $HOME/logs/$FOLDER_NAME/$VERSION/initialize_db.log | awk '{print $13}')
		printf "\t${bold}${green}Setting up SSL RSA${clear}\n"
		mysql_ssl_rsa_setup --datadir=data > $HOME/logs/$FOLDER_NAME/$VERSION/sslSetupLog.txt 2>&1
		printf "\t${bold}${green}Initial run${clear}\n"
		mysqld_safe --defaults-file=my.cnf --skip-grant-tables > $HOME/logs/$FOLDER_NAME/$VERSION/initializeStart.txt 2>&1 &

		PORT=$(grep -E '^ *port=' my.cnf | awk -F= '{print $2}' | tr -d ' ')

		printf "\t${bold}${green}Sleeping for 60s${clear}\n"
		sleep 60

		mysql -u root -S "data/mysql_$VERSION_STRING.sock" -P $PORT <<EOF
FLUSH PRIVILEGES;
CREATE USER 'shreyas'@'%' IDENTIFIED with mysql_native_password BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'shreyas'@'%';
FLUSH PRIVILEGES;
EOF

		bash stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files