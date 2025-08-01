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

POSTGIS_FOLDER_NAME=postgis
POSTGIS_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$POSTGIS_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/postgresql.conf ]; then
	print_message "postgresql.conf not found" $((DEPTH))
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/pg_hba.conf ]; then
	print_message "pg_hba.conf not found" $((DEPTH))
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/pg_ctl" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	cd $HOME/sources/$FOLDER_NAME

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="postgresql-$VERSION.tar.gz"
	wget -q "https://ftp.postgresql.org/pub/source/v$VERSION/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "postgresql-"$VERSION $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --without-readline --without-icu CFLAGS="-Wno-unguarded-availability-new" > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/pg_ctl" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		mkdir data
		print_message "${bold}${green}Initializing DB${clear}" $((DEPTH))
		initdb -d data > $HOME/logs/$FOLDER_NAME/$VERSION/dbInitialization.txt 2>&1

		mv data/postgresql.conf $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/postgresql.conf.default
		cp $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/postgresql.conf data/postgresql.conf
		mv data/pg_hba.conf $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/pg_hba.conf.default
		cp $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/pg_hba.conf data/pg_hba.conf

		touch start.sh
		echo "PORT=\$(grep 'port = ' data/postgresql.conf | awk '{print \$3}')" >> start.sh
		echo '' >> start.sh
		echo 'if [ ! -e data/postmaster.pid ]; then' >> start.sh
		echo -e '\techo "Starting"' >> start.sh
		echo -e "\tpg_ctl start -D data > postgresStart.txt 2>&1" >> start.sh
		echo 'fi' >> start.sh

		touch stop.sh
		echo "PORT=\$(grep 'port = ' data/postgresql.conf | awk '{print \$3}')" >> stop.sh
		echo '' >> stop.sh
		echo 'if [ -e data/postmaster.pid ]; then' >> stop.sh
		echo -e '\techo "Stopping"' >> stop.sh
		echo -e '\tpg_ctl stop -D data > postgresStop.txt 2>&1' >> stop.sh
		echo 'fi' >> stop.sh

		print_message "${bold}${green}Initial Start${clear}" $((DEPTH))
		bash start.sh > /dev/null 2>&1
		PORT=$(grep 'port = ' data/postgresql.conf | awk '{print $3}')
		print_message "${bold}${green}Creating Postgres User${clear}" $((DEPTH))
		createuser -p $PORT -s postgres > $HOME/logs/$FOLDER_NAME/$VERSION/postgresUserCreation.txt 2>&1
		print_message "${bold}${green}Creating DB${clear}" $((DEPTH))
		createdb -U postgres -p $PORT shreyas > $HOME/logs/$FOLDER_NAME/$VERSION/dbCreation.txt 2>&1
		print_message "${bold}${green}Creating User${clear}" $((DEPTH))
		psql -U postgres -p $PORT -w <<EOF
CREATE USER shreyas WITH ENCRYPTED PASSWORD 'password' SUPERUSER;
EOF

		bash stop.sh > /dev/null 2>&1

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))

		bash $INSTALL_FILES_DIR/$OS/$POSTGIS_FOLDER_NAME/$POSTGIS_VERSION/install.sh $VERSION $((DEPTH+1))
	fi
fi
