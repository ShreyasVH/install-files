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

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/rabbitmqadmin" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	mkdir $VERSION
	mkdir $VERSION/bin
	cd $VERSION
	ARCHIVE_FILE="rabbitmqadmin-${VERSION}-aarch64-apple-darwin"
	wget --show-progress "https://github.com/rabbitmq/rabbitmqadmin-ng/releases/download/v${VERSION}/$ARCHIVE_FILE" > $HOME/logs/$FOLDER_NAME/$VERSION/download.txt 2>&1
	mv $ARCHIVE_FILE bin/rabbitmqadmin
	chmod +x bin/rabbitmqadmin
	SUDO_ASKPASS=$HOME/askpass.sh sudo -A xattr -rd com.apple.quarantine bin/rabbitmqadmin

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	touch .envrc
	echo "export PATH=\$HOME/programs/$FOLDER_NAME/$VERSION/bin:\$PATH" >> .envrc
	direnv allow
fi

