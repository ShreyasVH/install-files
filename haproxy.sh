VERSION=2.8.2
MINOR_VERSION=2.8
OPENSSL_VERSION=3.0.10

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/haproxy" ]; then
	mkdir "$HOME/sources/haproxy"
fi

if [ ! -d "$HOME/programs/haproxy" ]; then
	mkdir "$HOME/programs/haproxy"
fi

if [ ! -d "$HOME/programs/haproxy/$VERSION" ]; then
	mkdir "$HOME/programs/haproxy/$VERSION"
fi

cd $HOME/sources/haproxy

make clean distclean

wget "https://www.haproxy.org/download/$MINOR_VERSION/src/haproxy-$VERSION.tar.gz"
tar -xvf "haproxy-$VERSION.tar.gz"
mv "haproxy-$VERSION" $VERSION
cd $VERSION
make PREFIX=$HOME/programs/haproxy/$VERSION TARGET=osx USE_OPENSSL=1 SSL_INC=$HOME/programs/openssl/$OPENSSL_VERSION/include SSL_LIB=$HOME/programs/openssl/$OPENSSL_VERSION/lib
sudo make install PREFIX=$HOME/programs/haproxy/$VERSION
