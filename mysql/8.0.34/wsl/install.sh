FOLDER_NAME=mysql
VERSION=8.0.34
MINOR_VERSION=8.0

CMAKE_FOLDER_NAME=cmake
CMAKE_VERSION=3.26.4

BOOST_FOLDER_NAME=boost

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=3.0.10

BISON_FOLDER_NAME=bison
BISON_VERSION=3.8.2

NCURSES_FOLDER_NAME=ncurses
NCURSES_VERSION=6.4

PKG_CONFIG_FOLDER_NAME=pkg-config
PKG_CONFIG_VERSION=0.29.2

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
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

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	bash $INSTALL_FILES_DIR/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$BISON_FOLDER_NAME/$BISON_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/wsl/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$CMAKE_FOLDER_NAME/$CMAKE_VERSION/bin:$PATH
	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH
	wget "https://dev.mysql.com/get/Downloads/MySQL-$MINOR_VERSION/mysql-$VERSION.tar.gz"
	tar -xvf "mysql-$VERSION.tar.gz"
	mv "mysql-"$VERSION $VERSION
	cd $VERSION
	mkdir bld
	cd bld
	export CPPFLAGS="-I$HOME/programs/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/include/ncurses -I$HOME/programs/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/include"
	export LDFLAGS="-L$HOME/programs/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/lib"
	cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=$HOME/programs/$BOOST_FOLDER_NAME -DCMAKE_INSTALL_PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION -DOPENSSL_ROOT_DIR=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION -DBISON_EXECUTABLE=$HOME/programs/$BISON_FOLDER_NAME/$BISON_VERSION/bin/bison -DCMAKE_PREFIX_PATH=$HOME/programs/$NCURSES_FOLDER_NAME/$NCURSES_VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

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
	echo "mysqld_safe --defaults-file=my.cnf &" >> start.sh

	touch stop.sh
	VERSION_STRING=$(echo "$VERSION" | sed 's/\./_/g')
	echo "mysqladmin --defaults-file=my.cnf -u shreyas -S data/mysql_$VERSION_STRING.sock --password=password shutdown" >> stop.sh

	mysqld --defaults-file=my.cnf --initialize 2> initialize_db.log
	TEMP_PASSWORD=$(grep -e 'A temporary password is generated for root@localhost: ' initialize_db.log | awk '{print $13}')
	echo $TEMP_PASSWORD
	mysql_ssl_rsa_setup --datadir=data
	mkdir data/logs
	mysqld_safe --defaults-file=my.cnf --skip-grant-tables &

	PORT=$(grep -E '^ *port=' my.cnf | awk -F= '{print $2}' | tr -d ' ')
	echo $PORT

	echo 'Sleeping for 60s'
	sleep 60

	mysql -u root -S "data/mysql_$VERSION_STRING.sock" -P $PORT <<EOF
FLUSH PRIVILEGES;
CREATE USER 'shreyas'@'%' IDENTIFIED with mysql_native_password BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'shreyas'@'%';
FLUSH PRIVILEGES;
EOF

	bash stop.sh

	# cd $HOME/sources/$FOLDER_NAME
	# rm -rf $VERSION
	# rm "mysql-$VERSION.tar.gz"
fi

cd $HOME/install-files