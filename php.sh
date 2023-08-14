VERSION=8.2.8
FOLDER_NAME=php
USER_NAME=shreyashande

LIBXML_VERSION=2.10.4
LIBXML_FOLDER_NAME=libxml2

OPENSSL_VERSION=3.0.10
OPENSSL_FOLDER_NAME=openssl

PKG_CONFIG_VERSION=0.29.2
PKG_CONFIG_FOLDER_NAME="pkg-config"

ZLIB_VERSION=1.2.13
ZLIB_FOLDER_NAME=zlib

CURL_VERSION=8.2.1
CURL_FOLDER_NAME=curl

SQLITE_VERSION=3.42.0
SQLITE_FOLDER_NAME=sqlite3

ONIGURUMA_VERSION=6.9.8
ONIGURUMA_FOLDER_NAME=oniguruma

AUTOCONF_VERSION=2.71
AUTOCONF_FOLDER_NAME=autoconf

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
	mkdir "$HOME/sources/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"
fi

cd $HOME/sources/$FOLDER_NAME

make clean distclean

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

wget "https://www.php.net/distributions/php-$VERSION.tar.gz"
tar -xvf "php-$VERSION.tar.gz"
mv "php-"$VERSION $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/php/$VERSION --with-apxs2=$HOME/programs/apache/2.4.57/bin/apxs --with-curl --with-openssl --with-pear --with-gettext --enable-mbstring --with-pdo-mysql --with-pdo-pgsql=$HOME/programs/postgres/15.2 --with-mysqli --with-gettext=$HOME/programs/gettext/0.21.1 --with-iconv=$HOME/programs/libiconv/1.17 --enable-sockets --with-zlib
make
sudo make install

export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

cd $HOME/programs/$FOLDER_NAME/$VERSION

sudo chown -R $USER_NAME .

wget http://curl.haxx.se/ca/cacert.pem
sudo mv cacert.pem $HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/ssl/cert.pem

EXTENSION_DIR=$HOME/programs/$FOLDER_NAME/$VERSION/lib/php/extensions/$(ls lib/php/extensions)
touch lib/php.ini

echo "extension_dir=$EXTENSION_DIR" >> lib/php.ini
echo "" >> lib/php.ini

sudo pecl channel-update pecl.php.net

sudo pecl install xdebug
echo "zend_extension=xdebug.so" >> lib/php.ini
echo "" >> lib/php.ini

sudo pecl install phalcon
echo "extension=phalcon.so" >> lib/php.ini
echo "" >> lib/php.ini