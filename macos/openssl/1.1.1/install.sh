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

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/openssl" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	cd $HOME/sources/$FOLDER_NAME

	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="openssl-${VERSION}w.tar.gz"
	curl -s -OL "https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/$ARCHIVE_FILE"
  print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "openssl-${VERSION}w" $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	ARCH=$(uname -m)
	ARCH_ARGS=("darwin64-${ARCH}-cc" "enable-ec_nistp_64_gcc_128")

	./Configure \
	  --prefix="$HOME/programs/$FOLDER_NAME/$VERSION" \
	  no-ssl3 no-ssl3-method no-zlib "${ARCH_ARGS[@]}" > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1

	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/openssl" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		print_message "${bold}${green}Installing Certificate${clear}" $((DEPTH))
		curl -s -O -L http://curl.haxx.se/ca/cacert.pem
		echo $USER_PASSWORD | sudo -S -p '' mv cacert.pem $HOME/programs/$FOLDER_NAME/$VERSION/ssl/cert.pem

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi