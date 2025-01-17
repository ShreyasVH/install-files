FOLDER_NAME=python
VERSION=3.11.3

PKG_CONFIG_FOLDER_NAME=pkg-config
PKG_CONFIG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PKG_CONFIG_FOLDER_NAME" '.[$folder][$version][$name]')

GETTEXT_FOLDER_NAME=gettext
GETTEXT_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$GETTEXT_FOLDER_NAME" '.[$folder][$version][$name]')

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=1.3

LIBFFI_VERSION=3.4.4
LIBFFI_FOLDER_NAME=libffi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/python3" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/wsl_20_04/install.sh
	bash $INSTALL_FILES_DIR/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/wsl_20_04/install.sh
	bash $INSTALL_FILES_DIR/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/wsl_20_04/install.sh
	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/wsl_20_04/install.sh
	bash $INSTALL_FILES_DIR/$LIBFFI_FOLDER_NAME/$LIBFFI_VERSION/wsl_20_04/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH="$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH"

	export LDFLAGS="-L$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/lib"
	export CPPFLAGS="-I$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/include"

	export PKG_CONFIG_PATH=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export ZLIB_CFLAGS=$(pkg-config --cflags zlib)
	export ZLIB_LIBS=$(pkg-config --libs zlib)

	export PKG_CONFIG_PATH=$HOME/programs/$LIBFFI_FOLDER_NAME/$LIBFFI_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export CFLAGS=$(pkg-config --cflags libffi)
	export LDFLAGS=$(pkg-config --libs libffi)

	export LD_LIBRARY_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib:$LD_LIBRARY_PATH

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="Python-"$VERSION".tgz"
	wget -q --show-progress "https://www.python.org/ftp/python/"$VERSION"/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "Python-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --with-pydebug --prefix="$HOME/programs/$FOLDER_NAME/$VERSION" --with-openssl=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	printf "\t${bold}${green}Making${clear}\n"
	make -s -j2 > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/install.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/python3" ]; then
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi
