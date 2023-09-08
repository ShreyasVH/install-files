VERSION=8.2.9
FOLDER_NAME=php

LIBXML_VERSION=2.10.4
LIBXML_FOLDER_NAME=libxml2

OPENSSL_VERSION=3.0.10
OPENSSL_FOLDER_NAME=openssl

PKG_CONFIG_VERSION=0.29.2
PKG_CONFIG_FOLDER_NAME="pkg-config"

ZLIB_VERSION=1.3
ZLIB_FOLDER_NAME=zlib

CURL_VERSION=8.2.1
CURL_FOLDER_NAME=curl

SQLITE_VERSION=3.42.0
SQLITE_FOLDER_NAME=sqlite3

ONIGURUMA_VERSION=6.9.8
ONIGURUMA_FOLDER_NAME=oniguruma

AUTOCONF_VERSION=2.71
AUTOCONF_FOLDER_NAME=autoconf

APACHE_FOLDER_NAME=apache
APACHE_VERSION=2.4.57

POSTGRES_FOLDER_NAME=postgres
POSTGRES_VERSION=15.4

GETTEXT_FOLDER_NAME=gettext
GETTEXT_VERSION=0.21.1

LIBICONV_FOLDER_NAME=libiconv
LIBICONV_VERSION=1.17

LIBMEMCACHED_FOLDER_NAME=libmemcached
LIBMEMCACHED_VERSION=1.0.18

PHP_EXTENSION_MEMCACHED_VERSION=3.2.0
PHP_EXTENSION_MEMCACHED_FOLDER_NAME=memcached
PHP_EXTENSION_XDEBUG_VERSION=3.2.2
PHP_EXTENSION_XDEBUG_FOLDER_NAME=xdebug
PHP_EXTENSION_PHALCON_VERSION=5.3.0
PHP_EXTENSION_PHALCON_FOLDER_NAME=phalcon

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

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION/extensions" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION/extensions"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/xdebug" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/xdebug"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/phalcon" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/phalcon"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/memcached" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION/extensions/memcached"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

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

	printf "${bold}${yellow}Installing $FOLDER_NAME${clear}\n"

	printf "\t${bold}${blink}${green}Downloading source code${clear}\n"
	wget -q "https://www.php.net/distributions/php-$VERSION.tar.gz"
	printf "\t${bold}${blink}${green}Extracting source code${clear}\n"
	tar -xf "php-$VERSION.tar.gz"
	mv "php-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${blink}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/php/$VERSION --with-apxs2=$HOME/programs/$APACHE_FOLDER_NAME/$APACHE_VERSION/bin/apxs --with-curl --with-openssl --with-pear --enable-mbstring --with-pdo-mysql --with-pdo-pgsql=$HOME/programs/$POSTGRES_FOLDER_NAME/$POSTGRES_VERSION --with-mysqli --with-gettext=$HOME/programs/$GETTEXT_FOLDER_NAME/$GETTEXT_VERSION --with-iconv=$HOME/programs/$LIBICONV_FOLDER_NAME/$LIBICONV_VERSION --enable-sockets --with-zlib > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	printf "\t${bold}${blink}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${blink}${green}Installing${clear}\n"
	sudo make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/php" ]; then

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		cd $HOME/programs/$FOLDER_NAME/$VERSION
		sudo chown -R $(whoami) .

		EXTENSION_DIR=$HOME/programs/$FOLDER_NAME/$VERSION/lib/php/extensions/$(ls lib/php/extensions)
		touch lib/php.ini

		echo "extension_dir=$EXTENSION_DIR" >> lib/php.ini
		echo "" >> lib/php.ini

		mkdir tmp
		pear config-set cache_dir $HOME/programs/$FOLDER_NAME/$VERSION/tmp
		pear config-set download_dir $HOME/programs/$FOLDER_NAME/$VERSION/tmp
		pear config-set temp_dir $HOME/programs/$FOLDER_NAME/$VERSION/tmp

		pecl channel-update pecl.php.net

		cd tmp
		printf "\t${bold}${yellow}Installing xdebug extension${clear}\n"
		printf "\t\t${bold}${blink}${green}Downloading source code${clear}\n"
		wget -q "https://pecl.php.net/get/xdebug-$PHP_EXTENSION_XDEBUG_VERSION.tgz"
		printf "\t\t${bold}${blink}${green}Extracting source code${clear}\n"
		tar -xf "xdebug-$PHP_EXTENSION_XDEBUG_VERSION.tgz"
		cd "xdebug-$PHP_EXTENSION_XDEBUG_VERSION"
		printf "\t\t${bold}${blink}${green}Running phpize${clear}\n"
		phpize > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_XDEBUG_FOLDER_NAME/phpizeOutput.txt 2>&1
		printf "\t\t${bold}${blink}${green}Configuring${clear}\n"
		./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_XDEBUG_FOLDER_NAME/configureHelp.txt 2>&1
		./configure > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_XDEBUG_FOLDER_NAME/configureOutput.txt 2>&1
		printf "\t\t${bold}${blink}${green}Making${clear}\n"
		make > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_XDEBUG_FOLDER_NAME/makeOutput.txt 2>&1
		mv modules/xdebug.so $EXTENSION_DIR
		cd ..
		rm "xdebug-$PHP_EXTENSION_XDEBUG_VERSION"
		rm "xdebug-$PHP_EXTENSION_XDEBUG_VERSION.tgz"
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo "zend_extension=xdebug.so" >> lib/php.ini
		echo "xdebug.idekey=PHPSTORM" > lib/php.ini
		echo "xdebug.mode=debug" > lib/php.ini
		echo "xdebug.client_host=127.0.0.1" > lib/php.ini
		echo "xdebug.client_port=9001" > lib/php.ini

		cd tmp
		printf "\t${bold}${yellow}Installing phalcon extension${clear}\n"
		printf "\t\t${bold}${blink}${green}Downloading source code${clear}\n"
		wget -q "https://pecl.php.net/get/phalcon-$PHP_EXTENSION_PHALCON_VERSION.tgz"
		printf "\t\t${bold}${blink}${green}Extracting source code${clear}\n"
		tar -xf "phalcon-$PHP_EXTENSION_PHALCON_VERSION.tgz"
		cd "phalcon-$PHP_EXTENSION_PHALCON_VERSION"
		printf "\t\t${bold}${blink}${green}Running phpize${clear}\n"
		phpize > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_PHALCON_FOLDER_NAME/phpizeOutput.txt 2>&1
		printf "\t\t${bold}${blink}${green}Configuring${clear}\n"
		./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_PHALCON_FOLDER_NAME/configureHelp.txt 2>&1
		./configure > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_PHALCON_FOLDER_NAME/configureOutput.txt 2>&1
		printf "\t\t${bold}${blink}${green}Making${clear}\n"
		make > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_PHALCON_FOLDER_NAME/makeOutput.txt 2>&1
		mv modules/phalcon.so $EXTENSION_DIR
		cd ..
		rm -rf "phalcon-$PHP_EXTENSION_PHALCON_VERSION"
		rm "phalcon-$PHP_EXTENSION_PHALCON_VERSION.tgz"
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo "extension=phalcon.so" >> lib/php.ini

		cd tmp
		printf "\t${bold}${yellow}Installing memcahced extension${clear}\n"
		printf "\t\t${bold}${blink}${green}Downloading source code${clear}\n"
		wget -q "https://pecl.php.net/get/memcached-$PHP_EXTENSION_MEMCACHED_VERSION.tgz"
		printf "\t\t${bold}${blink}${green}Extracting source code${clear}\n"
		tar -xf "memcached-$PHP_EXTENSION_MEMCACHED_VERSION.tgz"
		cd "memcached-$PHP_EXTENSION_MEMCACHED_VERSION"
		phpize > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_MEMCACHED_FOLDER_NAME/phpizeOutput.txt 2>&1
		./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_MEMCACHED_FOLDER_NAME/configureHelp.txt 2>&1
		./configure --with-libmemcached-dir=$HOME/programs/$LIBMEMCACHED_FOLDER_NAME/$LIBMEMCACHED_VERSION --with-zlib-dir=$HOME/programs/$ZLIB_FOLDER_NAME/$ZLIB_VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_MEMCACHED_FOLDER_NAME/configureOutput.txt 2>&1
		make > $HOME/logs/$FOLDER_NAME/$VERSION/extensions/$PHP_EXTENSION_MEMCACHED_FOLDER_NAME/makeOutput.txt 2>&1
		mv modules/memcached.so $EXTENSION_DIR
		cd ..
		rm "memcached-$PHP_EXTENSION_MEMCACHED_VERSION"
		rm "memcached-$PHP_EXTENSION_MEMCACHED_VERSION.tgz"
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo "extension=memcached.so" >> lib/php.ini

		pear install Console_Table

		php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
		php composer-setup.php
		mv composer.phar ~/programs/$FOLDER_NAME/$VERSION/bin/composer
		rm composer-setup.php

		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "php-$VERSION.tar.gz"
	fi
fi