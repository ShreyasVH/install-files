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

VERSION_STRING=$(echo "$VERSION" | sed 's/\./_/g')

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/boost.css" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH))

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE=boost-$VERSION.tar.gz
	wget -q -O $ARCHIVE_FILE "https://sourceforge.net/projects/boost/files/boost/$VERSION/boost_$VERSION_STRING.tar.gz/download"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	# mv "boost_$VERSION_STRING" $VERSION
	# cd $VERSION

	# echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	print_message "${bold}${green}Clearing${clear}" $((DEPTH))
	# cd ..
	rm $ARCHIVE_FILE
fi