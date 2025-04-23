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

PORT=514

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

AUTOCONF_FOLDER_NAME=autoconf
AUTOCONF_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$AUTOCONF_FOLDER_NAME" '.[$folder][$version][$name]')

AUTOMAKE_FOLDER_NAME=automake
AUTOMAKE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$AUTOMAKE_FOLDER_NAME" '.[$folder][$version][$name]')

LIBTOOL_FOLDER_NAME=libtool
LIBTOOL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBTOOL_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/rsyslog.conf ]; then
	print_message "${red}${bold}rsyslog.conf not found${clear}"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/rsyslogd" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$LIBESTR_FOLDER_NAME/$LIBESTR_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$LIBFASTJSON_FOLDER_NAME/$LIBFASTJSON_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$E2FSPROGS_FOLDER_NAME/$E2FSPROGS_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$LIBGCRYPT_FOLDER_NAME/$LIBGCRYPT_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$CURL_FOLDER_NAME/$CURL_VERSION/install.sh $((DEPTH+1))
	# bash $INSTALL_FILES_DIR/$OS/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/install.sh $((DEPTH+1))
	# bash $INSTALL_FILES_DIR/$OS/$AUTOMAKE_FOLDER_NAME/$AUTOMAKE_VERSION/install.sh $((DEPTH+1))
	# bash $INSTALL_FILES_DIR/$OS/$LIBTOOL_FOLDER_NAME/$LIBTOOL_VERSION/install.sh $((DEPTH+1))

	cd "$HOME/sources/$FOLDER_NAME"

	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH
	export PATH=$HOME/programs/$LIBGCRYPT_FOLDER_NAME/$LIBGCRYPT_VERSION/bin:$PATH
	# export PATH=$HOME/programs/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/bin:$PATH
	# export PATH=$HOME/programs/$AUTOMAKE_FOLDER_NAME/$AUTOMAKE_VERSION/bin:$PATH
	# export PATH=$HOME/programs/$LIBTOOL_FOLDER_NAME/$LIBTOOL_VERSION/bin:$PATH

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

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	# ARCHIVE_FILE="v$VERSION.tar.gz"
	# wget -q "https://github.com/rsyslog/rsyslog/archive/refs/tags/$ARCHIVE_FILE"
	ARCHIVE_FILE="rsyslog-$VERSION.tar.gz"
	wget -q "https://www.rsyslog.com/files/download/rsyslog/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "rsyslog-$VERSION" $VERSION
	cd $VERSION
	# print_message "${bold}${green}Running libtoolize${clear}" $((DEPTH))
	# libtoolize > $HOME/logs/$FOLDER_NAME/$VERSION/libtoolOutput.txt 2>&1
	# print_message "${bold}${green}Running aclocal${clear}" $((DEPTH))
	# aclocal > $HOME/logs/$FOLDER_NAME/$VERSION/aclocalOutput.txt 2>&1
	# print_message "${bold}${green}Running autoconf${clear}" $((DEPTH))
	# autoconf > $HOME/logs/$FOLDER_NAME/$VERSION/autoconfOutput.txt 2>&1
	# print_message "${bold}${green}Running automake${clear}" $((DEPTH))
	# automake --add-missing --copy > $HOME/logs/$FOLDER_NAME/$VERSION/automakeOutput.txt 2>&1
	# print_message "${bold}${green}Running autoreconf${clear}" $((DEPTH))
	# autoreconf -vfi > $HOME/logs/$FOLDER_NAME/$VERSION/autoreconfOutput.txt 2>&1
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/rsyslogd" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		touch start.sh
		echo "SUDO_ASKPASS=\$HOME/askpass.sh sudo -A  sbin/rsyslogd -f ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/rsyslog.conf &" >> start.sh

		touch stop.sh
		echo 'SUDO_ASKPASS=$HOME/askpass.sh sudo -A kill -9 $(SUDO_ASKPASS=$HOME/askpass.sh sudo -A lsof -t -i:'$PORT')' >> stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi