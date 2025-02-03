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

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=$(cat "$STATIC_VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ZLIB_FOLDER_NAME" '.[$folder][$version][$name]')

POSTGIS_FOLDER_NAME=postgis
POSTGIS_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$POSTGIS_FOLDER_NAME" '.[$folder][$version][$name]')

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/postgresql.conf ]; then
	printf "postgresql.conf not found\n"
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/pg_hba.conf ]; then
	printf "pg_hba.conf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/pg_ctl" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	export LDFLAGS="-L$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/lib"
	export CPPFLAGS="-I$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/include"

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="postgresql-$VERSION.tar.gz"
	wget -q "https://ftp.postgresql.org/pub/source/v$VERSION/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "postgresql-"$VERSION $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --without-readline > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/pg_ctl" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		mkdir data
		print_message "${bold}${green}Initializing DB${clear}" $((DEPTH))
		initdb -d data > $HOME/logs/$FOLDER_NAME/$VERSION/dbInitialization.txt 2>&1

		mv data/postgresql.conf ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/postgresql.conf.default
		ln -s ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/postgresql.conf data/postgresql.conf
		mv data/pg_hba.conf ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/pg_hba.conf.default
		ln -s ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/pg_hba.conf data/pg_hba.conf

		touch start.sh
		echo "pg_ctl start -D data > postgresStart.txt 2>&1" >> start.sh

		touch stop.sh
		echo 'pg_ctl stop -D data > postgresStop.txt 2>&1' >> stop.sh

		print_message "${bold}${green}Initial Start${clear}" $((DEPTH))
		bash start.sh
		PORT=$(grep 'port = ' data/postgresql.conf | awk '{print $3}')
		print_message "${bold}${green}Creating Postgres User${clear}" $((DEPTH))
		createuser -p $PORT -s postgres > $HOME/logs/$FOLDER_NAME/$VERSION/postgresUserCreation.txt 2>&1
		print_message "${bold}${green}Creating DB${clear}" $((DEPTH))
		createdb -U postgres -p $PORT shreyas > $HOME/logs/$FOLDER_NAME/$VERSION/dbCreation.txt 2>&1
		print_message "${bold}${green}Creating User${clear}" $((DEPTH))
		psql -U postgres -p $PORT -w <<EOF
CREATE USER shreyas WITH ENCRYPTED PASSWORD 'password' SUPERUSER;
EOF

		bash stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))

		cd $INSTALL_FILES_DIR
		bash $OS/$POSTGIS_FOLDER_NAME/$POSTGIS_VERSION/install.sh $VERSION $((DEPTH+1))
	fi
fi
