FOLDER_NAME=postgres
VERSION=15.4

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

if [ ! -d "$HOME/logs/$FOLDER_NAME" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION"
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/postgresql.conf ]; then
	printf "postgresql.conf not found\n"
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/pg_hba.conf ]; then
	printf "pg_hba.conf not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://ftp.postgresql.org/pub/source/v$VERSION/postgresql-$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "postgresql-$VERSION.tar.gz"
	mv "postgresql-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --without-readline > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	printf "\t${bold}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S -p '' make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

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

		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "postgresql-$VERSION.tar.gz"
	fi
fi
