VERSION=8.1.25
FOLDER_NAME=php

cd $INSTALL_FILES_DIR

LIBXML_FOLDER_NAME=libxml2
LIBXML_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBXML_FOLDER_NAME" '.[$folder][$version][$name]')

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$OPENSSL_FOLDER_NAME" '.[$folder][$version][$name]')

PKG_CONFIG_FOLDER_NAME="pkg-config"
PKG_CONFIG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PKG_CONFIG_FOLDER_NAME" '.[$folder][$version][$name]')

ZLIB_FOLDER_NAME=zlib
ZLIB_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ZLIB_FOLDER_NAME" '.[$folder][$version][$name]')

CURL_FOLDER_NAME=curl
CURL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$CURL_FOLDER_NAME" '.[$folder][$version][$name]')

SQLITE_FOLDER_NAME=sqlite3
SQLITE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$SQLITE_FOLDER_NAME" '.[$folder][$version][$name]')

ONIGURUMA_FOLDER_NAME=oniguruma
ONIGURUMA_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ONIGURUMA_FOLDER_NAME" '.[$folder][$version][$name]')

AUTOCONF_FOLDER_NAME=autoconf
AUTOCONF_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$AUTOCONF_FOLDER_NAME" '.[$folder][$version][$name]')

APACHE_FOLDER_NAME=apache
APACHE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$APACHE_FOLDER_NAME" '.[$folder][$version][$name]')

POSTGRES_FOLDER_NAME=postgres
POSTGRES_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$POSTGRES_FOLDER_NAME" '.[$folder][$version][$name]')

GETTEXT_FOLDER_NAME=gettext
GETTEXT_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$GETTEXT_FOLDER_NAME" '.[$folder][$version][$name]')


LIBINTL_LIB=$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/lib
LIBINTL_INC=$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/include

LIBICONV_FOLDER_NAME=libiconv
LIBICONV_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBICONV_FOLDER_NAME" '.[$folder][$version][$name]')

LIBMEMCACHED_FOLDER_NAME=libmemcached
LIBMEMCACHED_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBMEMCACHED_FOLDER_NAME" '.[$folder][$version][$name]')

PHP_EXTENSION_MEMCACHED_FOLDER_NAME=php-memcached
PHP_EXTENSION_MEMCACHED_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PHP_EXTENSION_MEMCACHED_FOLDER_NAME" '.[$folder][$version][$name]')
PHP_EXTENSION_XDEBUG_FOLDER_NAME=php-xdebug
PHP_EXTENSION_XDEBUG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PHP_EXTENSION_XDEBUG_FOLDER_NAME" '.[$folder][$version][$name]')
PHP_EXTENSION_PHALCON_FOLDER_NAME=php-phalcon
PHP_EXTENSION_PHALCON_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PHP_EXTENSION_PHALCON_FOLDER_NAME" '.[$folder][$version][$name]')
PHP_EXTENSION_REDIS_FOLDER_NAME=php-redis
PHP_EXTENSION_REDIS_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PHP_EXTENSION_REDIS_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/php" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION/extensions" ]; then
		mkdir "$HOME/logs/$FOLDER_NAME/$VERSION/extensions"
	fi

	if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_XDEBUG_FOLDER_NAME" ]; then
		mkdir "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_XDEBUG_FOLDER_NAME"
	fi

	if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_PHALCON_FOLDER_NAME" ]; then
		mkdir "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_PHALCON_FOLDER_NAME"
	fi

	if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_MEMCACHED_FOLDER_NAME" ]; then
		mkdir "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_MEMCACHED_FOLDER_NAME"
	fi

	if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_REDIS_FOLDER_NAME" ]; then
		mkdir "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_REDIS_FOLDER_NAME"
	fi

	bash $INSTALL_FILES_DIR/$LIBXML_FOLDER_NAME/$LIBXML_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$CURL_FOLDER_NAME/$CURL_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$ONIGURUMA_FOLDER_NAME/$ONIGURUMA_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$APACHE_FOLDER_NAME/$APACHE_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$LIBICONV_FOLDER_NAME/$LIBICONV_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$LIBMEMCACHED_FOLDER_NAME/$LIBMEMCACHED_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH

	export PKG_CONFIG_PATH=$HOME/programs/$LIBXML_FOLDER_NAME/$LIBXML_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export LIBXML_CFLAGS=$(pkg-config --cflags libxml-2.0)
	export LIBXML_LIBS=$(pkg-config --libs libxml-2.0)

	export PKG_CONFIG_PATH=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export OPENSSL_CFLAGS=$(pkg-config --cflags openssl)
	export OPENSSL_LIBS=$(pkg-config --libs openssl)

	export PKG_CONFIG_PATH=$HOME/programs/$SQLITE_FOLDER_NAME/$SQLITE_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export SQLITE_CFLAGS=$(pkg-config --cflags sqlite3)
	export SQLITE_LIBS=$(pkg-config --libs sqlite3)

	export PKG_CONFIG_PATH=$HOME/programs/$CURL_FOLDER_NAME/$CURL_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export CURL_CFLAGS=$(pkg-config --cflags libcurl)
	export CURL_LIBS=$(pkg-config --libs libcurl)

	export PKG_CONFIG_PATH=$HOME/programs/$ONIGURUMA_FOLDER_NAME/$ONIGURUMA_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export ONIG_CFLAGS=$(pkg-config --cflags oniguruma)
	export ONIG_LIBS=$(pkg-config --libs oniguruma)

	export PKG_CONFIG_PATH=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export ZLIB_CFLAGS=$(pkg-config --cflags zlib)
	export ZLIB_LIBS=$(pkg-config --libs zlib)

	export PATH=$HOME/programs/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/bin:$PATH

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="php-$VERSION.tar.gz"
	wget -q --show-progress "https://www.php.net/distributions/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "php-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/php/$VERSION --with-apxs2=$HOME/programs/$APACHE_FOLDER_NAME/$APACHE_VERSION/bin/apxs --with-curl --with-openssl --with-pear --enable-mbstring --with-pdo-mysql --with-pdo-pgsql=$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION --with-mysqli --with-gettext=$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION --with-iconv=$HOME/programs/$LIBICONV_FOLDER_NAME/$LIBICONV_VERSION --enable-sockets --with-zlib > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/php" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		EXTENSION_DIR=$HOME/programs/$FOLDER_NAME/$VERSION/lib/php/extensions/$(ls lib/php/extensions)
		touch lib/php.ini

		echo "extension_dir=$EXTENSION_DIR" >> lib/php.ini
		echo "" >> lib/php.ini

		mkdir tmp
		pear config-set cache_dir $HOME/programs/$FOLDER_NAME/$VERSION/tmp > /dev/null 2>&1
		pear config-set download_dir $HOME/programs/$FOLDER_NAME/$VERSION/tmp > /dev/null 2>&1
		pear config-set temp_dir $HOME/programs/$FOLDER_NAME/$VERSION/tmp > /dev/null 2>&1

		pecl channel-update pecl.php.net > /dev/null 2>&1

		cd tmp
		printf "\t${bold}${yellow}Installing xdebug extension${clear}\n"
		printf "\t\t${bold}${green}Downloading source code${clear}\n"
		wget -q "https://pecl.php.net/get/xdebug-$PHP_EXTENSION_XDEBUG_VERSION.tgz"
		printf "\t\t${bold}${green}Extracting source code${clear}\n"
		tar -xf "xdebug-$PHP_EXTENSION_XDEBUG_VERSION.tgz"
		cd "xdebug-$PHP_EXTENSION_XDEBUG_VERSION"
		printf "\t\t${bold}${green}Running phpize${clear}\n"
		phpize > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_XDEBUG_FOLDER_NAME/phpizeOutput.txt 2>&1
		printf "\t\t${bold}${green}Configuring${clear}\n"
		./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_XDEBUG_FOLDER_NAME/configureHelp.txt 2>&1
		./configure > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_XDEBUG_FOLDER_NAME/configureOutput.txt 2>&1
		printf "\t\t${bold}${green}Making${clear}\n"
		make > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_XDEBUG_FOLDER_NAME/makeOutput.txt 2>&1
		mv modules/xdebug.so $EXTENSION_DIR
		cd ..
		rm -rf "xdebug-$PHP_EXTENSION_XDEBUG_VERSION"
		rm "xdebug-$PHP_EXTENSION_XDEBUG_VERSION.tgz"
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo "zend_extension=xdebug.so" >> lib/php.ini
		echo "xdebug.idekey=PHPSTORM" >> lib/php.ini
		echo "xdebug.mode=debug" >> lib/php.ini
		echo "xdebug.client_host=127.0.0.1" >> lib/php.ini
		echo "xdebug.client_port=9001" >> lib/php.ini

		cd tmp
		printf "\t${bold}${yellow}Installing phalcon extension${clear}\n"
		printf "\t\t${bold}${green}Downloading source code${clear}\n"
		wget -q "https://pecl.php.net/get/phalcon-$PHP_EXTENSION_PHALCON_VERSION.tgz"
		printf "\t\t${bold}${green}Extracting source code${clear}\n"
		tar -xf "phalcon-$PHP_EXTENSION_PHALCON_VERSION.tgz"
		cd "phalcon-$PHP_EXTENSION_PHALCON_VERSION"
		printf "\t\t${bold}${green}Running phpize${clear}\n"
		phpize > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_PHALCON_FOLDER_NAME/phpizeOutput.txt 2>&1
		printf "\t\t${bold}${green}Configuring${clear}\n"
		./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_PHALCON_FOLDER_NAME/configureHelp.txt 2>&1
		./configure > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_PHALCON_FOLDER_NAME/configureOutput.txt 2>&1
		printf "\t\t${bold}${green}Making${clear}\n"
		make > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_PHALCON_FOLDER_NAME/makeOutput.txt 2>&1
		mv modules/phalcon.so $EXTENSION_DIR
		cd ..
		rm -rf "phalcon-$PHP_EXTENSION_PHALCON_VERSION"
		rm "phalcon-$PHP_EXTENSION_PHALCON_VERSION.tgz"
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo "extension=phalcon.so" >> lib/php.ini

		cd tmp
		printf "\t${bold}${yellow}Installing memcahced extension${clear}\n"
		printf "\t\t${bold}${green}Downloading source code${clear}\n"
		wget -q "https://pecl.php.net/get/memcached-$PHP_EXTENSION_MEMCACHED_VERSION.tgz"
		printf "\t\t${bold}${green}Extracting source code${clear}\n"
		tar -xf "memcached-$PHP_EXTENSION_MEMCACHED_VERSION.tgz"
		cd "memcached-$PHP_EXTENSION_MEMCACHED_VERSION"
		printf "\t\t${bold}${green}Running phpize${clear}\n"
		phpize > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_MEMCACHED_FOLDER_NAME/phpizeOutput.txt 2>&1
		printf "\t\t${bold}${green}Configuring${clear}\n"
		./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_MEMCACHED_FOLDER_NAME/configureHelp.txt 2>&1
		./configure --with-libmemcached-dir=$HOME/programs/$LIBMEMCACHED_FOLDER_NAME/$LIBMEMCACHED_VERSION --with-zlib-dir=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_MEMCACHED_FOLDER_NAME/configureOutput.txt 2>&1
		printf "\t\t${bold}${green}Making${clear}\n"
		make > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_MEMCACHED_FOLDER_NAME/makeOutput.txt 2>&1
		mv modules/memcached.so $EXTENSION_DIR
		cd ..
		rm -rf "memcached-$PHP_EXTENSION_MEMCACHED_VERSION"
		rm "memcached-$PHP_EXTENSION_MEMCACHED_VERSION.tgz"
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo "extension=memcached.so" >> lib/php.ini

		cd tmp
		printf "\t${bold}${yellow}Installing redis extension${clear}\n"
		printf "\t\t${bold}${green}Downloading source code${clear}\n"
		wget -q "https://pecl.php.net/get/redis-$PHP_EXTENSION_REDIS_VERSION.tgz"
		printf "\t\t${bold}${green}Extracting source code${clear}\n"
		tar -xf "redis-$PHP_EXTENSION_REDIS_VERSION.tgz"
		cd "redis-$PHP_EXTENSION_REDIS_VERSION"
		printf "\t\t${bold}${green}Running phpize${clear}\n"
		phpize > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_REDIS_FOLDER_NAME/phpizeOutput.txt 2>&1
		printf "\t\t${bold}${green}Configuring${clear}\n"
		./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_REDIS_FOLDER_NAME/configureHelp.txt 2>&1
		./configure > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_REDIS_FOLDER_NAME/configureOutput.txt 2>&1
		printf "\t\t${bold}${green}Making${clear}\n"
		make > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_REDIS_FOLDER_NAME/makeOutput.txt 2>&1
		mv modules/redis.so $EXTENSION_DIR
		cd ..
		rm -rf "redis-$PHP_EXTENSION_REDIS_VERSION"
		rm "redis-$PHP_EXTENSION_REDIS_VERSION.tgz"
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo "extension=redis.so" >> lib/php.ini

		printf "\t${bold}${green}Installing Console Table${clear}\n"
		pear install Console_Table > $HOME/logs/$FOLDER_NAME/$VERSION/consoleTableInstallation.txt 2>&1

		printf "\t${bold}${green}Installing Composer${clear}\n"
		php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" > $HOME/logs/$FOLDER_NAME/$VERSION/composerInstallation.txt 2>&1
		printf "\t${bold}${green}Setting up Composer${clear}\n"
		php composer-setup.php > $HOME/logs/$FOLDER_NAME/$VERSION/composerSetup.txt 2>&1
		mv composer.phar ~/programs/$FOLDER_NAME/$VERSION/bin/composer
		rm composer-setup.php

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi