VERSION=1.6.3
APR_VERSION=1.7.4

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/apr-util" ]; then
	mkdir "$HOME/sources/apr-util"
fi

if [ ! -d "$HOME/programs/apr-util" ]; then
	mkdir "$HOME/programs/apr-util"
fi

if [ ! -d "$HOME/programs/apr-util/$VERSION" ]; then
	mkdir "$HOME/programs/apr-util/$VERSION"
fi

cd $HOME/sources/apr-util

make clean distclean

wget "https://archive.apache.org/dist/apr/apr-util-"$VERSION".tar.gz"
tar -xvf "apr-util-"$VERSION".tar.gz"
mv "apr-util-"$VERSION $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/apr-util/$VERSION --with-apr=$HOME/programs/apr/$APR_VERSION/bin/apr-1-config
make
sudo make install
