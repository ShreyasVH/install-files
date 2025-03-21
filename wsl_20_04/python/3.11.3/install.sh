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

PKG_CONFIG_FOLDER_NAME=pkg-config
PKG_CONFIG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PKG_CONFIG_FOLDER_NAME" '.[$folder][$version][$name]')

GETTEXT_FOLDER_NAME=gettext
GETTEXT_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$GETTEXT_FOLDER_NAME" '.[$folder][$version][$name]')

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=$(cat "$STATIC_VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ZLIB_FOLDER_NAME" '.[$folder][$version][$name]')

LIBFFI_FOLDER_NAME=libffi
LIBFFI_VERSION=$(cat "$STATIC_VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBFFI_FOLDER_NAME" '.[$folder][$version][$name]')

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/python3" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$LIBFFI_FOLDER_NAME/$LIBFFI_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	export PATH="$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH"

	export LDFLAGS="-L$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/lib"
	export CPPFLAGS="-I$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/include"

	export PKG_CONFIG_PATH=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export ZLIB_CFLAGS=$(pkg-config --cflags zlib)
	export ZLIB_LIBS=$(pkg-config --libs zlib)

	export PKG_CONFIG_PATH=$HOME/programs/$LIBFFI_FOLDER_NAME/$LIBFFI_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export CFLAGS="$(pkg-config --cflags libffi) $CFLAGS"
	export LDFLAGS="$(pkg-config --libs libffi) $LDFLAGS"

	export PKG_CONFIG_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export CFLAGS="$(pkg-config --cflags openssl) $CFLAGS"
	export LDFLAGS="$(pkg-config --libs openssl) $LDFLAGS"

	# export LD_LIBRARY_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib:$LD_LIBRARY_PATH

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="Python-"$VERSION".tgz"
	wget -q "https://www.python.org/ftp/python/"$VERSION"/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "Python-"$VERSION $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	# export LD_LIBRARY_PATH=/home/shreyas/programs/openssl/3.1.0/lib:/home/shreyas/programs/libffi/3.4.4/lib:$LD_LIBRARY_PATH
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --with-pydebug --prefix="$HOME/programs/$FOLDER_NAME/$VERSION" --with-openssl=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION LDFLAGS="-L/home/shreyas/programs/libffi/$LIBFFI_VERSION/lib -L/home/shreyas/programs/openssl/$OPENSSL_VERSION/lib -Wl,-rpath=/home/shreyas/programs/openssl/$OPENSSL_VERSION/lib:/home/shreyas/programs/libffi/$LIBFFI_VERSION/lib" CFLAGS="-I/home/shreyas/programs/libffi/$LIBFFI_VERSION/include -I/home/shreyas/programs/openssl/$OPENSSL_VERSION/include" > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	print_message "${bold}${green}Making${clear}" $((DEPTH))
	make -s -j2 > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/install.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/python3" ]; then
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi
