VERSION=3.0.10

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/openssl" ]; then
	mkdir "$HOME/sources/openssl"
fi

if [ ! -d "$HOME/programs/openssl" ]; then
	mkdir "$HOME/programs/openssl"
fi

if [ ! -d "$HOME/programs/openssl/$VERSION" ]; then
	mkdir "$HOME/programs/openssl/$VERSION"
fi

cd $HOME/sources/openssl

make clean distclean

wget "https://www.openssl.org/source/openssl-$VERSION.tar.gz"
tar -xvf "openssl-$VERSION.tar.gz"
mv "openssl-$VERSION" $VERSION
cd $VERSION

./config --prefix=$HOME/programs/openssl/$VERSION --libdir=lib shared zlib-dynamic
make
sudo make install