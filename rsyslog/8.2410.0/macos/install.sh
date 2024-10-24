VERSION=8.2410.0
FOLDER_NAME=rsyslog
PORT=514

cd $INSTALL_FILES_DIR

LIBESTR_FOLDER_NAME=libestr
LIBESTR_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBESTR_FOLDER_NAME" '.[$folder][$version][$name]')

PKG_CONFIG_FOLDER_NAME="pkg-config"
PKG_CONFIG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PKG_CONFIG_FOLDER_NAME" '.[$folder][$version][$name]')

LIBFASTJSON_FOLDER_NAME=libfastjson
LIBFASTJSON_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBFASTJSON_FOLDER_NAME" '.[$folder][$version][$name]')

E2FSPROGS_FOLDER_NAME=e2fsprogs
E2FSPROGS_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$E2FSPROGS_FOLDER_NAME" '.[$folder][$version][$name]')

LIBGCRYPT_FOLDER_NAME=libgcrypt
LIBGCRYPT_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBGCRYPT_FOLDER_NAME" '.[$folder][$version][$name]')

CURL_FOLDER_NAME=curl
CURL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$CURL_FOLDER_NAME" '.[$folder][$version][$name]')

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ZLIB_FOLDER_NAME" '.[$folder][$version][$name]')

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/rsyslog.conf ]; then
	printf "rsyslog.conf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/rsyslogd" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

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

	export PKG_CONFIG_PATH=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export ZLIB_CFLAGS=$(pkg-config --cflags zlib)
	export ZLIB_LIBS=$(pkg-config --libs zlib)

	export PKG_CONFIG_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export OPENSSL_CFLAGS=$(pkg-config --cflags openssl)
	export OPENSSL_LIBS=$(pkg-config --libs openssl)

	export PKG_CONFIG_PATH=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export CURL_CFLAGS=$(pkg-config --cflags libcurl)
	export CURL_LIBS=$(pkg-config --libs libcurl)

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="rsyslog-$VERSION.tar.gz"
	wget -q --show-progress "https://www.rsyslog.com/files/download/rsyslog/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "rsyslog-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/rsyslogd" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		touch start.sh
		echo "echo $USER_PASSWORD | sudo -S -p '' sbin/rsyslogd -f ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/rsyslog.conf &" >> start.sh

		touch stop.sh
		echo 'echo '$USER_PASSWORD' | sudo -S -p '' sudo kill -9 $(sudo lsof -t -i:'$PORT')' >> stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi