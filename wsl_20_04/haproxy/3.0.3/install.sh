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

MAJOR_VERSION=$(echo $VERSION | cut -d '.' -f 1)
MINOR_VERSION=$(echo $VERSION | cut -d '.' -f 2)
VERSION_STRING=$MAJOR_VERSION"."$MINOR_VERSION

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/haproxy.cfg ]; then
	printf "haproxy.cfg not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/haproxy" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="haproxy-$VERSION.tar.gz"
	wget -q "https://www.haproxy.org/download/$VERSION_STRING/src/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "haproxy-$VERSION" $VERSION
	cd $VERSION
	print_message "${bold}${green}Making${clear}" $((DEPTH))
	make -j$PROCESS_COUNT PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION TARGET=linux-glibc USE_OPENSSL=1 SSL_INC=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/include SSL_LIB=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	print_message "${bold}${green}Installing${clear}" $((DEPTH))
	echo $USER_PASSWORD | sudo -S -p '' make install PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/haproxy" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/sbin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		cp $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/haproxy.cfg haproxy.cfg
		touch start.sh
		echo 'PORT=80' >> start.sh
		echo '' >> start.sh
		echo 'if ! SUDO_ASKPASS=$HOME/askpass.sh sudo -A lsof -i :$PORT > /dev/null; then' >> start.sh
		echo -e '\techo "Starting"' >> start.sh
		echo -e '\texport LD_LIBRARY_PATH=$HOME/programs/'$OPENSSL_FOLDER_NAME'/'$OPENSSL_VERSION'/lib:$LD_LIBRARY_PATH' >> start.sh
		echo -e '\tSUDO_ASKPASS=$HOME/askpass.sh sudo -A LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./sbin/haproxy -f haproxy.cfg -D' >> start.sh
		echo 'fi' >> start.sh

		touch stop.sh
		echo 'PORT=80' >> stop.sh
		echo '' >> stop.sh
		echo 'if SUDO_ASKPASS=$HOME/askpass.sh sudo -A lsof -i :$PORT > /dev/null; then' >> stop.sh
		echo -e '\techo "Stopping"' >> stop.sh
		echo -e "\tSUDO_ASKPASS=\$HOME/askpass.sh sudo -A kill -9 \$(cat \$HOME/pids/haproxy.pid)" >> stop.sh
		echo 'fi' >> stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi
