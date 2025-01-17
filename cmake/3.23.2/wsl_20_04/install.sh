FOLDER_NAME=cmake
VERSION=3.23.2

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=3.0.10

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/cmake" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/wsl_20_04/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export OPENSSL_ROOT_DIR=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="cmake-$VERSION.tar.gz"
	wget -q --show-progress "https://github.com/Kitware/CMake/releases/download/v$VERSION/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "cmake-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${green}Bootstrapping${clear}\n"
	./bootstrap --help > $HOME/logs/$FOLDER_NAME/$VERSION/bootstrapHelp.txt 2>&1
	./bootstrap --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/bootstrapOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/cmake" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files