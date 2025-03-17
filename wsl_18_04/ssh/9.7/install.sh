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

PORT=22

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=$(cat "$STATIC_VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ZLIB_FOLDER_NAME" '.[$folder][$version][$name]')

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$STATIC_VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/ssh" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="openssh-"$VERSION"p1.tar.gz"
	wget -q "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "openssh-"$VERSION"p1" $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	export LD_LIBRARY_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib:$LD_LIBRARY_PATH
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-zlib=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION --with-ssl-dir=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION --without-openssl-header-check > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/ssh" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		echo $USER_PASSWORD | sudo -S -p '' groupadd sshd
		echo $USER_PASSWORD | sudo -S -p '' useradd -g sshd -c 'sshd privsep' -d /var/empty -s /bin/false sshd

		print_message "${bold}${green}Creating host keys${clear}" $((DEPTH))
		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH
		export LD_LIBRARY_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib:$LD_LIBRARY_PATH
		ssh-keygen -A > /dev/null

		touch start.sh
		echo 'export LD_LIBRARY_PATH=$HOME/programs/'$OPENSSL_FOLDER_NAME'/'$OPENSSL_VERSION'/lib:$LD_LIBRARY_PATH' >> start.sh
		echo '' >> start.sh
		echo 'SUDO_ASKPASS=$HOME/askpass.sh sudo LD_LIBRARY_PATH="$LD_LIBRARY_PATH" -A /home/'$(whoami)'/programs/'$FOLDER_NAME'/'$VERSION'/sbin/sshd' >> start.sh

		touch stop.sh
		echo 'echo opensesame | sudo -S -p "" kill -9 $(echo opensesame | sudo -S -p "" lsof -t -i:'$PORT')' >> stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi

cd $HOME/install-files