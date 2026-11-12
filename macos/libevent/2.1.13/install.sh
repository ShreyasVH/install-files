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

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(jq -r --arg folder "${OPENSSL_FOLDER_NAME}" '.[$folder]' latestVersions.json)

PKG_CONFIG_FOLDER_NAME="pkg-config"
PKG_CONFIG_VERSION=$(jq -r --arg folder "${PKG_CONFIG_FOLDER_NAME}" '.[$folder]' latestVersions.json)

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libevent.dylib" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/install.sh $((DEPTH+1))

	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH

	cd "$HOME/sources/$FOLDER_NAME"

	export PKG_CONFIG_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	LINK="$(get_protocol_for_binary "https")://$(get_domain_for_binary "github.com")/libevent/libevent/releases/download/release-$VERSION-stable/libevent-$VERSION-stable.tar.gz"
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
	
	mv "libevent-$VERSION-stable" $VERSION
	cd $VERSION
	
	print_message "${bold}${green}Configuring${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libevent.dylib" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .
		
		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi