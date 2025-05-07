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

APR_FOLDER_NAME=apr
APR_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$APR_FOLDER_NAME" '.[$folder][$version][$name]')

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/apu-1-config" ]; then
	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH))
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$OS/$APR_FOLDER_NAME/$APR_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="apr-util-"$VERSION".tar.gz"
	wget -q "https://archive.apache.org/dist/apr/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "apr-util-"$VERSION $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-apr=$HOME/programs/apr/$APR_VERSION/bin/apr-1-config > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/apu-1-config" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi

cd $HOME/install-files