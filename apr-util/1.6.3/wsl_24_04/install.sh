FOLDER_NAME=apr-util
VERSION=1.6.3

cd $INSTALL_FILES_DIR

APR_FOLDER_NAME=apr
APR_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$APR_FOLDER_NAME" '.[$folder][$version][$name]')

LIBEXPAT_FOLDER_NAME=libexpat
LIBEXPAT_VERSION=2.4.1

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/apu-1-config" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$APR_FOLDER_NAME/$APR_VERSION/wsl_24_04/install.sh
	bash $INSTALL_FILES_DIR/$LIBEXPAT_FOLDER_NAME/$LIBEXPAT_VERSION/wsl_24_04/install.sh

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="apr-util-"$VERSION".tar.gz"
	wget -q --show-progress "https://archive.apache.org/dist/apr/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "apr-util-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-apr=$HOME/programs/apr/$APR_VERSION/bin/apr-1-config --with-expat=$HOME/programs/$LIBEXPAT_FOLDER_NAME/$LIBEXPAT_VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/apu-1-config" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files