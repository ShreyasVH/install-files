FOLDER_NAME=phpmyadmin
VERSION=5.2.1

PHP_FOLDER_NAME=php
PHP_VERSION=8.2.14

cd $INSTALL_FILES_DIR

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/config.inc.php ]; then
	printf "config.inc.php not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/index.php" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	bash $INSTALL_FILES_DIR/$PHP_FOLDER_NAME/$PHP_VERSION/macos/install.sh

	cd $HOME/programs/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://files.phpmyadmin.net/phpMyAdmin/$VERSION/phpMyAdmin-$VERSION-all-languages.zip"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	unzip "phpMyAdmin-$VERSION-all-languages.zip" > /dev/null 2>&1
	mv "phpMyAdmin-$VERSION-all-languages" $VERSION
	cd $VERSION

	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$PHP_FOLDER_NAME/$PHP_VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	touch start.sh
	PORT=9100
	echo "php -S '0.0.0.0:$PORT' -t . > phpmyadmin.log 2>&1 &" >> start.sh

	touch stop.sh
	echo 'kill -9 $(lsof -t -i:'$PORT')' >> stop.sh

	mv config.sample.inc.php ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/config.inc.php.default
	ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/config.inc.php ./

	printf "\t${bold}${green}Clearing${clear}\n"
	cd ..
	rm "phpMyAdmin-$VERSION-all-languages.zip"
fi