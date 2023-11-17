FOLDER_NAME=apache
VERSION=2.4.58

APR_FOLDER_NAME=apr
APR_VERSION=1.7.4

APR_UTIL_FOLDER_NAME=apr-util
APR_UTIL_VERSION=1.6.3

PCRE_FOLDER_NAME=pcre2
PCRE_VERSION=10.42

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

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/httpd.conf ]; then
	printf "httpd.conf not found\n"
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/httpd-vhosts.conf ]; then
	printf "httpd-vhosts.conf not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	bash $INSTALL_FILES_DIR/$APR_FOLDER_NAME/$APR_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$APR_UTIL_FOLDER_NAME/$APR_UTIL_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$PCRE_FOLDER_NAME/$PCRE_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://archive.apache.org/dist/httpd/httpd-$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "httpd-"$VERSION".tar.gz"
	mv "httpd-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-apr=$HOME/programs/$APR_FOLDER_NAME/$APR_VERSION/bin/apr-1-config --with-apr-util=$HOME/programs/$APR_UTIL_FOLDER_NAME/$APR_UTIL_VERSION/bin/apu-1-config --with-pcre=$HOME/programs/$PCRE_FOLDER_NAME/$PCRE_VERSION/bin/pcre2-config > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	printf "\t${bold}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/apachectl" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S chown -R $(whoami) .

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


		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "httpd-"$VERSION".tar.gz"
	fi
fi

