FOLDER_NAME=ruby
VERSION=3.3.4
MINOR_VERSION=3.3

cd $INSTALL_FILES_DIR

LIBYAML_FOLDER_NAME=libyaml
LIBYAML_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBYAML_FOLDER_NAME" '.[$folder][$version][$name]')

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/ruby" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$LIBYAML_FOLDER_NAME/$LIBYAML_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="ruby-$VERSION.tar.gz"
	wget -q --show-progress "https://cache.ruby-lang.org/pub/ruby/$MINOR_VERSION/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "ruby-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --without-baseruby --with-openssl-dir=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION --with-libyaml-dir=$HOME/programs/$LIBYAML_FOLDER_NAME/$LIBYAML_VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/ruby" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

