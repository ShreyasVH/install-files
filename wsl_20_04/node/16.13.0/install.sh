version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)

program_dir=$(dirname "$version_dir")
FOLDER_NAME=$(basename $program_dir)

DEPTH=1
if [ $# -ge 1 ]; then
    DEPTH=$1
fi

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/node" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME
	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH+1))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH+2))
	wget -q "https://nodejs.org/dist/v$VERSION/node-v$VERSION-linux-x64.tar.xz"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH+2))
	tar -xf "node-v$VERSION-linux-x64.tar.xz"
	mv "node-v$VERSION-linux-x64" $VERSION
	cd $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/node" ]; then
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		print_message "${bold}${green}Installing yarn${clear}" $((DEPTH+2))
		npm i --global yarn > /dev/null 2>&1

		print_message "${bold}${green}Clearing${clear}" $((DEPTH+2))
		cd ..
		rm "node-v$VERSION-linux-x64.tar.xz"
	fi
fi

cd $HOME/install-files
