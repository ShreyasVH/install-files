VERSION=2.4.57
APR_VERSION=1.7.4
APR_UTIL_VERSION=1.6.3
PCRE_VERSION=10.42

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/apache" ]; then
	mkdir "$HOME/sources/apache"
fi

if [ ! -d "$HOME/programs/apache" ]; then
	mkdir "$HOME/programs/apache"
fi

if [ ! -d "$HOME/programs/apache/$VERSION" ]; then
	mkdir "$HOME/programs/apache/$VERSION"
fi

cd $HOME/sources/apache

make clean distclean

wget "https://dlcdn.apache.org/httpd/httpd-"$VERSION".tar.gz"
tar -xvf "httpd-"$VERSION".tar.gz"
mv "httpd-"$VERSION $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/apache/$VERSION --with-apr=$HOME/programs/apr/$APR_VERSION/bin/apr-1-config --with-apr-util=$HOME/programs/apr-util/$APR_UTIL_VERSION/bin/apu-1-config --with-pcre=$HOME/programs/pcre2/$PCRE_VERSION/bin/pcre2-config
make
sudo make install

