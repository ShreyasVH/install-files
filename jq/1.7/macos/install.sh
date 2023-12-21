FOLDER_NAME=jq
VERSION=1.7

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/jq" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"
	cd $HOME/programs/$FOLDER_NAME/$VERSION

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	curl -O -L "https://github.com/jqlang/jq/releases/download/jq-$VERSION/jq-macos-arm64"
	echo $USER_PASSWORD | sudo -S -p '' chmod +x jq-macos-arm64
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION/bin"
	mv jq-macos-arm64 bin/jq

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow
fi

cd $HOME/install-files