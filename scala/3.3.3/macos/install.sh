VERSION=3.3.3
FOLDER_NAME=scala

cd $INSTALL_FILES_DIR

JAVA_FOLDER_NAME=java
JAVA_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$JAVA_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	bash $INSTALL_FILES_DIR/$JAVA_FOLDER_NAME/$JAVA_VERSION/macos/install.sh

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://github.com/lampepfl/dotty/releases/download/$VERSION/scala3-$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "scala3-$VERSION.tar.gz"
	mv "scala3-$VERSION" $VERSION
	cd $VERSION

	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	echo 'export JAVA_HOME=$HOME/programs/'"$JAVA_FOLDER_NAME/$JAVA_VERSION" >> .envrc
	echo "" >> .envrc
	direnv allow

	printf "\t${bold}${green}Clearing${clear}\n"
	cd ..
	rm "scala3-$VERSION.tar.gz"
fi

