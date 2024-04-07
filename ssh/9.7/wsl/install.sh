FOLDER_NAME=ssh
VERSION=9.7

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=1.3

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=3.2.1

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/ssh" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/wsl/install.sh

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="openssh-"$VERSION"p1.tar.gz"
	printf "$ARCHIVE_FILE"
	printf "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/$ARCHIVE_FILE"
	wget -q --show-progress "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "openssh-"$VERSION"p1" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-zlib=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION --with-ssl-dir=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION --without-openssl-header-check > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/ssh" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		echo $USER_PASSWORD | sudo -S -p '' groupadd sshd
		echo $USER_PASSWORD | sudo -S -p '' useradd -g sshd -c 'sshd privsep' -d /var/empty -s /bin/false sshd

		touch start.sh
		echo "sudo /home/$(whoami)/programs/$FOLDER_NAME/$VERSION/sbin/sshd" >> start.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files