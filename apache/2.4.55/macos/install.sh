FOLDER_NAME=apache
VERSION=2.4.55

cd $INSTALL_FILES_DIR

APR_FOLDER_NAME=apr
APR_VERSION=1.7.2

APR_UTIL_FOLDER_NAME=apr-util
APR_UTIL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$APR_UTIL_FOLDER_NAME" '.[$folder][$version][$name]')

PCRE_FOLDER_NAME=pcre2
PCRE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PCRE_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/httpd.conf ]; then
	printf "httpd.conf not found\n"
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/httpd-vhosts.conf ]; then
	printf "httpd-vhosts.conf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/apachectl" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$APR_FOLDER_NAME/$APR_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$APR_UTIL_FOLDER_NAME/$APR_UTIL_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$PCRE_FOLDER_NAME/$PCRE_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="httpd-$VERSION.tar.gz"
	wget -q --show-progress "https://archive.apache.org/dist/httpd/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "httpd-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-apr=$HOME/programs/$APR_FOLDER_NAME/$APR_VERSION/bin/apr-1-config --with-apr-util=$HOME/programs/$APR_UTIL_FOLDER_NAME/$APR_UTIL_VERSION/bin/apu-1-config --with-pcre=$HOME/programs/$PCRE_FOLDER_NAME/$PCRE_VERSION/bin/pcre2-config > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/apachectl" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		mv conf/httpd.conf ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/httpd.conf.default
		ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/httpd.conf conf/httpd.conf
		mv conf/extra/httpd-vhosts.conf ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/httpd-vhosts.conf.default
		ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/httpd-vhosts.conf conf/extra/httpd-vhosts.conf
		echo "<html><body><h1>It works! (version: $VERSION)</h1></body></html>" > htdocs/index.html

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		touch start.sh
		echo "apachectl start" >> start.sh

		touch stop.sh
		echo 'apachectl stop' >> stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

