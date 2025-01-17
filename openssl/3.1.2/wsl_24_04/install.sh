FOLDER_NAME=openssl
VERSION=3.1.2

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=1.3

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/openssl" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/wsl_24_04/install.sh

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="openssl-$VERSION.tar.gz"
	curl -OL "https://github.com/openssl/openssl/releases/download/openssl-$VERSION/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "openssl-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./config --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./config --prefix=$HOME/programs/openssl/$VERSION --libdir=lib --with-zlib-lib=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/lib --with-zlib-include=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/include > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/openssl" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t\t${bold}${green}Installing Certificate${clear}\n"
		curl -O -L http://curl.haxx.se/ca/cacert.pem
		echo $USER_PASSWORD | sudo -S -p '' mv cacert.pem $HOME/programs/$FOLDER_NAME/$VERSION/ssl/cert.pem

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files