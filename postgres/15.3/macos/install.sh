FOLDER_NAME=postgres
VERSION=15.3

cd $INSTALL_FILES_DIR

POSTGIS_FOLDER_NAME=postgis
POSTGIS_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$POSTGIS_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/postgresql.conf ]; then
	printf "postgresql.conf not found\n"
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/pg_hba.conf ]; then
	printf "pg_hba.conf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/pg_ctl" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="postgresql-$VERSION.tar.gz"
	wget -q --show-progress "https://ftp.postgresql.org/pub/source/v$VERSION/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "postgresql-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --without-readline > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/pg_ctl" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		mkdir data
		printf "\t${bold}${green}Initializing DB${clear}\n"
		initdb -d data > $HOME/logs/$FOLDER_NAME/$VERSION/dbInitialization.txt 2>&1

		mv data/postgresql.conf ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/postgresql.conf.default
		ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/postgresql.conf data/postgresql.conf
		mv data/pg_hba.conf ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/pg_hba.conf.default
		ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/pg_hba.conf data/pg_hba.conf

		touch start.sh
		echo "pg_ctl start -D data > postgresStart.txt 2>&1" >> start.sh

		touch stop.sh
		echo 'pg_ctl stop -D data > postgresStop.txt 2>&1' >> stop.sh

		printf "\t${bold}${green}Initial Start${clear}\n"
		bash start.sh
		PORT=$(grep 'port = ' data/postgresql.conf | awk '{print $3}')
		printf "\t${bold}${green}Creating Postgres User${clear}\n"
		createuser -p $PORT -s postgres > $HOME/logs/$FOLDER_NAME/$VERSION/postgresUserCreation.txt 2>&1
		printf "\t${bold}${green}Creating DB${clear}\n"
		createdb -U postgres -p $PORT shreyas > $HOME/logs/$FOLDER_NAME/$VERSION/dbCreation.txt 2>&1
		printf "\t${bold}${green}Creating User${clear}\n"
		psql -U postgres -p $PORT -w <<EOF
CREATE USER shreyas WITH ENCRYPTED PASSWORD 'password' SUPERUSER;
EOF

		bash stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE

		bash $INSTALL_FILES_DIR/$POSTGIS_FOLDER_NAME/$POSTGIS_VERSION/macos/install.sh $VERSION

		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) $HOME/programs/$FOLDER_NAME/$VERSION
	fi
fi
