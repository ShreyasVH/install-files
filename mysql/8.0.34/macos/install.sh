FOLDER_NAME=mysql
VERSION=8.0.34
MINOR_VERSION=8.0

CMAKE_FOLDER_NAME=cmake
CMAKE_VERSION=3.26.4

BOOST_FOLDER_NAME=boost

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=3.1.1

BISON_FOLDER_NAME=bison
BIRSON_VERSION=3.8.2

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/logs" ]; then
	mkdir "$HOME/logs"
fi

if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
	mkdir "$HOME/sources/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$BOOST_FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$BOOST_FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	bash $INSTALL_FILES_DIR/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$BISON_FOLDER_NAME/$BIRSON_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/bin:$PATH

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://dev.mysql.com/get/Downloads/MySQL-$MINOR_VERSION/mysql-$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "mysql-$VERSION.tar.gz"
	mv "mysql-"$VERSION $VERSION
	cd $VERSION
	mkdir bld
	cd bld
	printf "\t${bold}${green}Running cmake${clear}\n"
	cmake --help > $HOME/logs/$FOLDER_NAME/$VERSION/cmakeHelp.txt 2>&1
	cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=$HOME/programs/$BOOST_FOLDER_NAME -DCMAKE_INSTALL_PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION -DOPENSSL_ROOT_DIR=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION -DBISON_EXECUTABLE=$HOME/programs/$BISON_FOLDER_NAME/$BIRSON_VERSION/bin/bison > $HOME/logs/$FOLDER_NAME/$VERSION/cmakeOutput.txt 2>&1
	printf "\t${bold}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S -p '' make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

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
		ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/my.cnf ./

		printf "\t${bold}${green}Initial Start${clear}\n"
		touch start.sh
		echo "mysqld_safe --defaults-file=my.cnf > mysql.log 2>&1 &" >> start.sh

		touch stop.sh
		VERSION_STRING=$(echo "$VERSION" | sed 's/\./_/g')
		echo "mysqladmin --defaults-file=my.cnf -u shreyas -S data/mysql_$VERSION_STRING.sock --password=password shutdown > shutdown.log 2>&1" >> stop.sh

		printf "\t${bold}${green}Initializing DB${clear}\n"
		mysqld --defaults-file=my.cnf --initialize 2> initialize_db.log
		TEMP_PASSWORD=$(grep -e 'A temporary password is generated for root@localhost: ' initialize_db.log | awk '{print $13}')
		mysql_ssl_rsa_setup --datadir=data > $HOME/logs/$FOLDER_NAME/$VERSION/rsaSetup.txt 2>&1
		mysqld_safe --defaults-file=my.cnf --skip-grant-tables &

		PORT=$(grep -E '^ *port=' my.cnf | awk -F= '{print $2}' | tr -d ' ')

		printf "\t${bold}${green}Sleeping for 60s${clear}\n"
		sleep 60

		printf "\t${bold}${green}Creating User${clear}\n"
		mysql -u root -S "data/mysql_$VERSION_STRING.sock" -P $PORT <<EOF
FLUSH PRIVILEGES;
CREATE USER 'shreyas'@'%' IDENTIFIED with mysql_native_password BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'shreyas'@'%';
FLUSH PRIVILEGES;
EOF

		bash stop.sh

		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "mysql-$VERSION.tar.gz"
	fi
fi

cd $HOME/install-files