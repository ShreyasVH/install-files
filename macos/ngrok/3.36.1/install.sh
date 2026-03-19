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

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/ngrok" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="ngrok-v${VERSION}-darwin-arm64.zip"
	wget --show-progress "https://bin.equinox.io/c/bNyj1mQVY4c/$ARCHIVE_FILE" > $HOME/logs/$FOLDER_NAME/$VERSION/download.txt 2>&1
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	mkdir $VERSION
	mkdir $VERSION/bin
	tar -xf $ARCHIVE_FILE
	mv ngrok $VERSION/bin
	cd $VERSION

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	touch .envrc
	echo "export PATH=\$HOME/programs/$FOLDER_NAME/$VERSION/bin:\$PATH" >> .envrc
	
	direnv allow

	export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH
	ngrok config add-authtoken $NGROK_TOKEN > $HOME/logs/$FOLDER_NAME/$VERSION/addToken.log 2>&1

	print_message "${bold}${green}Clearing${clear}" $((DEPTH))
	cd ..
	rm $ARCHIVE_FILE
fi

