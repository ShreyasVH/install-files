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

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/minikube" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	mkdir $HOME/programs/$FOLDER_NAME/$VERSION
	mkdir $HOME/programs/$FOLDER_NAME/$VERSION/bin
	cd $HOME/programs/$FOLDER_NAME/$VERSION
	ARCHIVE_FILE="minikube-linux-amd64"
	wget --show-progress "https://github.com/kubernetes/minikube/releases/download/v${VERSION}/$ARCHIVE_FILE" > $HOME/logs/$FOLDER_NAME/$VERSION/download.txt 2>&1
	print_message "${bold}${green}Installing${clear}" $((DEPTH))
	SUDO_ASKPASS=$HOME/askpass.sh sudo -A install minikube-linux-amd64 $HOME/programs/$FOLDER_NAME/$VERSION/bin/minikube > $HOME/logs/$FOLDER_NAME/$VERSION/install.txt 2>&1
	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) $HOME/programs/$FOLDER_NAME/$VERSION

	touch .envrc
	echo "export PATH=\$HOME/programs/$FOLDER_NAME/$VERSION/bin:\$PATH" >> .envrc
	echo "" >> .envrc
	direnv allow

	touch start.sh
	echo -e 'echo "Starting"' >> start.sh
	echo -e 'minikube start' >> start.sh

	touch stop.sh
	echo -e 'echo "Stopping"' >> stop.sh
	echo -e 'minikube stop' >> stop.sh
fi