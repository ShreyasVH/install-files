FOLDER_NAME=haproxy
VERSION=2.8.3
MINOR_VERSION=2.8

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=3.1.2

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/logs" ]; then
	mkdir "$HOME/logs"
fi

if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
	mkdir "$HOME/sources/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION"
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/haproxy.cfg ]; then
	printf "haproxy.cfg not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://www.haproxy.org/download/$MINOR_VERSION/src/haproxy-$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "haproxy-$VERSION.tar.gz"
	mv "haproxy-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Making${clear}\n"
	make PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION TARGET=osx USE_OPENSSL=1 SSL_INC=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/include SSL_LIB=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S -p '' make install PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/haproxy" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/sbin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		touch start.sh
		echo "echo $USER_PASSWORD | sudo -S -p '' haproxy -f ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/haproxy.cfg -D" >> start.sh

		touch stop.sh
		echo 'echo '$USER_PASSWORD' | sudo -S -p "" kill -9 $(echo '$USER_PASSWORD' | sudo -S -p "" lsof -t -i:80)' >> stop.sh

		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "haproxy-$VERSION.tar.gz"
	fi
fi
