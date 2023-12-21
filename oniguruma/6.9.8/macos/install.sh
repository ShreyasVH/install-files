VERSION=6.9.8
FOLDER_NAME=oniguruma

cd $INSTALL_FILES_DIR

AUTOCONF_FOLDER_NAME=autoconf
AUTOCONF_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$AUTOCONF_FOLDER_NAME" '.[$folder][$version][$name]')

AUTOMAKE_FOLDER_NAME=automake
AUTOMAKE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$AUTOMAKE_FOLDER_NAME" '.[$folder][$version][$name]')

LIBTOOL_FOLDER_NAME=libtool
LIBTOOL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBTOOL_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/onig-config" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$AUTOMAKE_FOLDER_NAME/$AUTOMAKE_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$LIBTOOL_FOLDER_NAME/$LIBTOOL_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/bin:$PATH
	export PATH=$HOME/programs/$AUTOMAKE_FOLDER_NAME/$AUTOMAKE_VERSION/bin:$PATH
	export PATH=$HOME/programs/$LIBTOOL_FOLDER_NAME/$LIBTOOL_VERSION/bin:$PATH
	export LIBTOOL=$HOME/programs/$LIBTOOL_FOLDER_NAME/$LIBTOOL_VERSION/bin/libtool

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="onig-$VERSION.tar.gz"
	wget -q --show-progress "https://github.com/kkos/oniguruma/releases/download/v$VERSION/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "onig-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${green}Running libtoolize${clear}\n"
	libtoolize > $HOME/logs/$FOLDER_NAME/$VERSION/libtoolOutput.txt 2>&1
	printf "\t${bold}${green}Running aclocal${clear}\n"
	aclocal > $HOME/logs/$FOLDER_NAME/$VERSION/aclocalOutput.txt 2>&1
	printf "\t${bold}${green}Running autoconf${clear}\n"
	autoconf > $HOME/logs/$FOLDER_NAME/$VERSION/autoconfOutput.txt 2>&1
	printf "\t${bold}${green}Running automake${clear}\n"
	automake --add-missing --copy > $HOME/logs/$FOLDER_NAME/$VERSION/automakeOutput.txt 2>&1
	printf "\t${bold}${green}Running autoreconf${clear}\n"
	autoreconf -vfi > $HOME/logs/$FOLDER_NAME/$VERSION/autoreconfOutput.txt 2>&1
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/onig-config" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files