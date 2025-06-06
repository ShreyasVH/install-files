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

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/jq" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"
	cd $HOME/programs/$FOLDER_NAME/$VERSION

	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	curl -s -O -L "https://github.com/jqlang/jq/releases/download/jq-$VERSION/jq-macos-arm64"
	echo $USER_PASSWORD | sudo -S -p '' chmod +x jq-macos-arm64
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION/bin"
	mv jq-macos-arm64 bin/jq

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow
fi

