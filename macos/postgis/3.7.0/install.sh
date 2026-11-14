version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)

program_dir=$(dirname "$version_dir")
FOLDER_NAME=$(basename $program_dir)

os_dir=$(dirname $program_dir)
OS=$(basename $os_dir)

DEPTH=2
if [ $# -ge 2 ]; then
    DEPTH=$2
fi

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ $# -lt 1 ]; then
    printf "${bold}${red}Usage: $0 <arg1>${clear}"
    exit 1
fi

POSTGRES_FOLDER_NAME=postgres
POSTGRES_VERSION=$1

LIBXML_FOLDER_NAME=libxml2
LIBXML_VERSION=$(jq -r --arg folder "${LIBXML_FOLDER_NAME}" '.[$folder]' latestVersions.json)

GEOS_FOLDER_NAME=geos
GEOS_VERSION=$(jq -r --arg folder "${GEOS_FOLDER_NAME}" '.[$folder]' latestVersions.json)

PROJ_FOLDER_NAME=proj
PROJ_VERSION=$(jq -r --arg folder "${PROJ_FOLDER_NAME}" '.[$folder]' latestVersions.json)

PKG_CONFIG_FOLDER_NAME="pkg-config"
PKG_CONFIG_VERSION=$(jq -r --arg folder "${PKG_CONFIG_FOLDER_NAME}" '.[$folder]' latestVersions.json)

SQLITE_FOLDER_NAME=sqlite3
SQLITE_VERSION=$(jq -r --arg folder "${SQLITE_FOLDER_NAME}" '.[$folder]' latestVersions.json)

LIBTIFF_FOLDER_NAME=libtiff
LIBTIFF_VERSION=$(jq -r --arg folder "${LIBTIFF_FOLDER_NAME}" '.[$folder]' latestVersions.json)

CURL_FOLDER_NAME=curl
CURL_VERSION=$(jq -r --arg folder "${CURL_FOLDER_NAME}" '.[$folder]' latestVersions.json)

GETTEXT_FOLDER_NAME=gettext
GETTEXT_VERSION=$(jq -r --arg folder "${GETTEXT_FOLDER_NAME}" '.[$folder]' latestVersions.json)

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=$(jq -r --arg folder "${ZLIB_FOLDER_NAME}" '.[$folder]' latestVersions.json)

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(jq -r --arg folder "${OPENSSL_FOLDER_NAME}" '.[$folder]' latestVersions.json)

GMP_FOLDER_NAME=gmp
GMP_VERSION=$(jq -r --arg folder "${GMP_FOLDER_NAME}" '.[$folder]' latestVersions.json)

EXECUTABLE_PATH=$(jq -r --arg folder "${FOLDER_NAME}" '.[$folder].path' programData.json)

if [ ! -e "$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION${EXECUTABLE_PATH}" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$LIBXML_FOLDER_NAME/$LIBXML_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$GEOS_FOLDER_NAME/$GEOS_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$PROJ_FOLDER_NAME/$PROJ_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$CURL_FOLDER_NAME/$CURL_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$GMP_FOLDER_NAME/$GMP_VERSION/install.sh $((DEPTH+1))

	export PATH=$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/bin:$PATH
	export PATH=$HOME/programs/$LIBXML_FOLDER_NAME/$LIBXML_VERSION/bin:$PATH
	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH

	export DYLD_LIBRARY_PATH=$HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib:$DYLD_LIBRARY_PATH
	export DYLD_LIBRARY_PATH=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib:$DYLD_LIBRARY_PATH

	export PKG_CONFIG_PATH=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$LIBTIFF_FOLDER_NAME/$LIBTIFF_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PKG_CONFIG_PATH=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH

	export PKG_CONFIG_PATH=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export PROJ_CFLAGS=$(pkg-config --cflags proj)
	export PROJ_LIBS=$(pkg-config --libs proj)

	export PKG_CONFIG_PATH=$HOME/programs/$GMP_FOLDER_NAME/$GMP_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export GMP_CFLAGS=$(pkg-config --cflags gmp)
	export GMP_LIBS=$(pkg-config --libs gmp)

	export CFLAGS="-I$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/include $CFLAGS"

	cd $HOME/sources/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	LINK="$(get_protocol_for_binary "https")://$(get_domain_for_binary "postgis.net")/stuff/postgis-$VERSION.tar.gz"
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
	
	mv "postgis-$VERSION" $VERSION
	cd $VERSION
	
	print_message "${bold}${green}Configuring${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	export LDFLAGS="-Wl,-headerpad_max_install_names"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION --with-projdir=$HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION --with-geosconfig=$HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/bin/geos-config --without-protobuf --without-raster --with-gettext=$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION --with-libintl-prefix=$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION --disable-rpath > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION${EXECUTABLE_PATH}" ]; then
		cd $HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		install_name_tool -change @rpath/libgeos_c.dylib $HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib/libgeos_c.dylib $HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/lib/postgis-3.dylib
		install_name_tool -change @rpath/libproj.dylib $HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib/libproj.dylib $HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/lib/postgis-3.dylib
		install_name_tool -change @rpath/libgeos.dylib $HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib/libgeos.dylib $HOME/programs/$GEOS_FOLDER_NAME/$GEOS_VERSION/lib/libgeos_c.dylib
		install_name_tool -change libsqlite3.dylib $HOME/programs/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/lib/libsqlite3.dylib $HOME/programs/$PROJ_FOLDER_NAME/$PROJ_VERSION/lib/libproj.dylib

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi

