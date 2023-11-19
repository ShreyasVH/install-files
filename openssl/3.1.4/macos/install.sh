FOLDER_NAME=openssl
VERSION=3.1.4

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

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	cd $HOME/sources/openssl

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	curl -O "https://www.openssl.org/source/openssl-$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "openssl-$VERSION.tar.gz"
	mv "openssl-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./config --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./config --prefix=$HOME/programs/openssl/$VERSION --libdir=lib shared zlib-dynamic > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	printf "\t${bold}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S -p '' make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

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

		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "openssl-$VERSION.tar.gz"
	fi
fi

cd $HOME/install-files