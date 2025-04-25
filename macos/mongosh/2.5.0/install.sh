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

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	wget -q "https://downloads.mongodb.com/compass/mongosh-$VERSION-darwin-arm64.zip"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	unzip "mongosh-$VERSION-darwin-arm64.zip" > /dev/null 2>&1
	mv "mongosh-$VERSION-darwin-arm64" $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mongosh" ]; then
		cd $VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		print_message "${bold}${green}Clearing${clear}" $((DEPTH))
		cd ..
		rm "mongosh-$VERSION-darwin-arm64.zip"
	fi
fi

cd $HOME/install-files