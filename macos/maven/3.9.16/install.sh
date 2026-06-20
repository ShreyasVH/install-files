version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)
MAJOR_VERSION=$(echo $VERSION | cut -d '.' -f 1)

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


if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0
	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE=apache-maven-$VERSION-bin.tar.gz
	wget -q "https://archive.apache.org/dist/maven/maven-$MAJOR_VERSION/$VERSION/binaries/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "apache-maven-"$VERSION $VERSION

	cd $VERSION
	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	print_message "${bold}${green}Clearing${clear}" $((DEPTH))
	cd ..
	rm $ARCHIVE_FILE
fi
