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
LIBESTR_VERSION=$(jq -r --arg folder "${LIBESTR_FOLDER_NAME}" '.[$folder]' latestVersions.json)

PKG_CONFIG_FOLDER_NAME="pkg-config"
PKG_CONFIG_VERSION=$(jq -r --arg folder "${PKG_CONFIG_FOLDER_NAME}" '.[$folder]' latestVersions.json)

LIBFASTJSON_FOLDER_NAME=libfastjson
LIBFASTJSON_VERSION=$(jq -r --arg folder "${LIBFASTJSON_FOLDER_NAME}" '.[$folder]' latestVersions.json)

E2FSPROGS_FOLDER_NAME=e2fsprogs
E2FSPROGS_VERSION=$(jq -r --arg folder "${E2FSPROGS_FOLDER_NAME}" '.[$folder]' latestVersions.json)

LIBGCRYPT_FOLDER_NAME=libgcrypt
LIBGCRYPT_VERSION=$(jq -r --arg folder "${LIBGCRYPT_FOLDER_NAME}" '.[$folder]' latestVersions.json)

CURL_FOLDER_NAME=curl
CURL_VERSION=$(jq -r --arg folder "${CURL_FOLDER_NAME}" '.[$folder]' latestVersions.json)

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=$(jq -r --arg folder "${ZLIB_FOLDER_NAME}" '.[$folder]' latestVersions.json)

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(jq -r --arg folder "${OPENSSL_FOLDER_NAME}" '.[$folder]' latestVersions.json)

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/rsyslog.conf ]; then
	print_message "${red}${bold}rsyslog.conf not found${clear}"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/rsyslogd" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$LIBESTR_FOLDER_NAME/$LIBESTR_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$LIBFASTJSON_FOLDER_NAME/$LIBFASTJSON_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$E2FSPROGS_FOLDER_NAME/$E2FSPROGS_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$LIBGCRYPT_FOLDER_NAME/$LIBGCRYPT_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$CURL_FOLDER_NAME/$CURL_VERSION/install.sh $((DEPTH+1))

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

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	LINK="$(get_protocol_for_binary "https")://$(get_domain_for_binary "www.rsyslog.com")/files/download/rsyslog/rsyslog-$VERSION.tar.gz"
	ARCHIVE_FILE="$(basename ${LINK})"
	start_time=$(date +%s)
	start_time_total=$(date +%s)
	download_binary "${FOLDER_NAME}" "${VERSION}" "${LINK}" "wget" "${DEPTH}"
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	tar -xf $ARCHIVE_FILE
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	mv "rsyslog-$VERSION" $VERSION
	cd $VERSION
	
	print_message "${bold}${green}Configuring${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --disable-libgcrypt --disable-impstats-push --disable-libyaml --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
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

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi