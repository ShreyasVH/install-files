script_dir=$(dirname "$(realpath "$0")")
version_dir=$(dirname "$script_dir")

VERSION=$(basename $version_dir)
MAJOR_VERSION=$(echo $VERSION | cut -d '.' -f 1)

program_dir=$(dirname "$version_dir")
FOLDER_NAME=$(basename $program_dir)

DEPTH=1
if [ $# -ge 1 ]; then
    DEPTH=$1
fi

source $INSTALL_FILES_DIR/utils.sh

# cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libmsodbcsql.$MAJOR_VERSION.dylib" ]; then
	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH+1))

	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH+2))
	ARCHIVE_FILE="msodbcsql$MAJOR_VERSION-$VERSION-arm64.tar.gz"
	wget -q "https://download.microsoft.com/download/f/0/e/f0e1f86e-1647-480f-b649-27741eea9642/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH+2))
	tar -xf $ARCHIVE_FILE
	mv "msodbcsql-$VERSION" $VERSION
	cd $VERSION
	if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libmsodbcsql.$MAJOR_VERSION.dylib" ]; then
		print_message "${bold}${green}Clearing${clear}" $((DEPTH+2))
		cd ..
		rm $ARCHIVE_FILE
	fi
fi

