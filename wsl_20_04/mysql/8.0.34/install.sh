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

CMAKE_FOLDER_NAME=cmake
CMAKE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$CMAKE_FOLDER_NAME" '.[$folder][$version][$name]')

BOOST_FOLDER_NAME=boost
BOOST_VERSION=$(cat "$STATIC_VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$BOOST_FOLDER_NAME" '.[$folder][$version][$name]')

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

BISON_FOLDER_NAME=bison
BISON_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$BISON_FOLDER_NAME" '.[$folder][$version][$name]')

NCURSES_FOLDER_NAME=ncurses
NCURSES_VERSION=$(cat "$STATIC_VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$NCURSES_FOLDER_NAME" '.[$folder][$version][$name]')

PKG_CONFIG_FOLDER_NAME=pkg-config
PKG_CONFIG_VERSION=$(cat "$STATIC_VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PKG_CONFIG_FOLDER_NAME" '.[$folder][$version][$name]')

LIBTIRPC_FOLDER_NAME=libtirpc
LIBTIRPC_VERSION=$(cat "$STATIC_VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBTIRPC_FOLDER_NAME" '.[$folder][$version][$name]')

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/my.cnf ]; then
	printf "my.cnf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mysql" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$BISON_FOLDER_NAME/$BISON_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$LIBTIRPC_FOLDER_NAME/$LIBTIRPC_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$BOOST_FOLDER_NAME/$BOOST_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/bin:$PATH
	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH
	export LD_LIBRARY_PATH=$HOME/programs/$LIBTIRPC_FOLDER_NAME/$LIBTIRPC_VERSION/lib:$LD_LIBRARY_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$LIBTIRPC_FOLDER_NAME/$LIBTIRPC_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	
	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="mysql-$VERSION.tar.gz"
	wget -q "https://dev.mysql.com/get/Downloads/MySQL-$MINOR_VERSION/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "mysql-"$VERSION $VERSION
	cd $VERSION
	mkdir bld
	cd bld
	export CPPFLAGS="-I$HOME/programs/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/include/ncurses -I$HOME/programs/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/include"
	export LDFLAGS="-L$HOME/programs/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/lib"
	print_message "${bold}${green}Running cmake${clear}" $((DEPTH))
	cmake .. -DWITH_BOOST=$HOME/programs/$BOOST_FOLDER_NAME -DCMAKE_INSTALL_PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION -DOPENSSL_ROOT_DIR=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION -DBISON_EXECUTABLE=$HOME/programs/$BISON_FOLDER_NAME/$BISON_VERSION/bin/bison -DCMAKE_PREFIX_PATH=$HOME/programs/$NCURSES_FOLDER_NAME/$NCURSES_VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/cmakeOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mysql" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH
		export PATH=$HOME/programs/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/bin:$PATH
		export PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/bin:$PATH
		export LD_LIBRARY_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib:$LD_LIBRARY_PATH

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		mkdir data
		ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/my.cnf ./

		touch start.sh
		echo "mysqld_safe --defaults-file=my.cnf > mysql.log 2>&1 &" >> start.sh

		touch stop.sh
		VERSION_STRING=$(echo "$VERSION" | sed 's/\./_/g')
		echo "mysqladmin --defaults-file=my.cnf -u shreyas -S data/mysql_$VERSION_STRING.sock --password=password shutdown" >> stop.sh

		print_message "${bold}${green}Initializing DB${clear}" $((DEPTH))
		mysqld --defaults-file=my.cnf --initialize 2> initialize_db.log
		TEMP_PASSWORD=$(grep -e 'A temporary password is generated for root@localhost: ' initialize_db.log | awk '{print $13}')
		print_message "${bold}${green}Setting up SSL RSA${clear}" $((DEPTH))
		mysql_ssl_rsa_setup --datadir=data > $HOME/logs/$FOLDER_NAME/$VERSION/sslSetupLog.txt 2>&1
		print_message "${bold}${green}Initial run${clear}" $((DEPTH))
		mysqld_safe --defaults-file=my.cnf --skip-grant-tables > $HOME/logs/$FOLDER_NAME/$VERSION/initializeStart.txt 2>&1 &

		PORT=$(grep -E '^ *port=' my.cnf | awk -F= '{print $2}' | tr -d ' ')

		print_message "${bold}${green}Sleeping for 60s${clear}" $((DEPTH))
		sleep 60

		mysql -u root -S "data/mysql_$VERSION_STRING.sock" -P $PORT <<EOF
FLUSH PRIVILEGES;
CREATE USER 'shreyas'@'%' IDENTIFIED with mysql_native_password BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'shreyas'@'%';
FLUSH PRIVILEGES;
EOF

		bash stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi

cd $HOME/install-files