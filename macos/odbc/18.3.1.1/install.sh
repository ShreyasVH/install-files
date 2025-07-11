version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)
MAJOR_VERSION=$(echo $VERSION | cut -d '.' -f 1)
echo $MAJOR_VERSION

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

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libmsodbcsql.$MAJOR_VERSION.dylib" ]; then
	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="msodbcsql$MAJOR_VERSION-$VERSION-arm64.tar.gz"
	wget -q "https://download.microsoft.com/download/d/4/7/d47963dd-a254-4d67-a92a-d3d5466df7e4/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "msodbcsql-$VERSION" $VERSION
	cd $VERSION
	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libmsodbcsql.$MAJOR_VERSION.dylib" ]; then
		print_message "${bold}${green}Clearing${clear}" $((DEPTH))
		cd ..
		rm $ARCHIVE_FILE
	fi
fi

