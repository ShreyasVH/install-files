VERSION=8.2308.0
FOLDER_NAME=rsyslog

LIBESTR_FOLDER_NAME=libestr
LIBESTR_VERSION=0.1.11

PKG_CONFIG_VERSION=0.29.2
PKG_CONFIG_FOLDER_NAME="pkg-config"

LIBFASTJSON_FOLDER_NAME=libfastjson
LIBFASTJSON_VERSION=1.2304.0

E2FSPROGS_FOLDER_NAME=e2fsprogs
E2FSPROGS_VERSION=1.47.0

LIBGCRYPT_FOLDER_NAME=libgcrypt
LIBGCRYPT_VERSION=1.10.2

CURL_VERSION=8.2.1
CURL_FOLDER_NAME=curl

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

if [ ! -d "$HOME/logs/$FOLDER_NAME" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	bash $INSTALL_FILES_DIR/$LIBESTR_FOLDER_NAME/$LIBESTR_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$LIBFASTJSON_FOLDER_NAME/$LIBFASTJSON_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$E2FSPROGS_FOLDER_NAME/$E2FSPROGS_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$LIBGCRYPT_FOLDER_NAME/$LIBGCRYPT_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$CURL_FOLDER_NAME/$CURL_VERSION/macos/install.sh

	cd "$HOME/sources/$FOLDER_NAME"

	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH
	export PATH=$HOME/programs/$LIBGCRYPT_FOLDER_NAME/$LIBGCRYPT_VERSION/bin:$PATH

	export PKG_CONFIG_PATH=$HOME/programs/$LIBESTR_FOLDER_NAME/$LIBESTR_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export LIBESTR_CFLAGS=$(pkg-config --cflags libestr)
	export LIBESTR_LIBS=$(pkg-config --libs libestr)

	export PKG_CONFIG_PATH=$HOME/programs/$LIBFASTJSON_FOLDER_NAME/$LIBFASTJSON_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export LIBFASTJSON_CFLAGS=$(pkg-config --cflags libfastjson)
	export LIBFASTJSON_LIBS=$(pkg-config --libs libfastjson)

	export PKG_CONFIG_PATH=$HOME/programs/$E2FSPROGS_FOLDER_NAME/$E2FSPROGS_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export LIBUUID_CFLAGS=$(pkg-config --cflags uuid)
	export LIBUUID_LIBS=$(pkg-config --libs uuid)

	export PKG_CONFIG_PATH=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export CURL_CFLAGS=$(pkg-config --cflags libcurl)
	export CURL_LIBS=$(pkg-config --libs libcurl)

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q "https://www.rsyslog.com/files/download/rsyslog/rsyslog-$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "rsyslog-$VERSION.tar.gz"
	mv "rsyslog-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	printf "\t${bold}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	sudo make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/sbin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	touch start.sh
	echo "sudo sbin/rsyslogd -f ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/rsyslog.conf &" >> start.sh

	touch stop.sh
	echo 'sudo kill -9 $(sudo lsof -t -i:514)' >> stop.sh

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/rsyslogd" ]; then
		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "rsyslog-$VERSION.tar.gz"
	fi
fi