VERSION=1.7.4

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/apr" ]; then
	mkdir "$HOME/sources/apr"
fi

if [ ! -d "$HOME/programs/apr" ]; then
	mkdir "$HOME/programs/apr"
fi

if [ ! -d "$HOME/programs/apr/$VERSION" ]; then
	mkdir "$HOME/programs/apr/$VERSION"
fi

cd $HOME/sources/apr

make clean distclean

wget "https://archive.apache.org/dist/apr/apr-"$VERSION".tar.gz"
tar -xvf "apr-"$VERSION".tar.gz"
mv "apr-"$VERSION $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/apr/$VERSION
make
sudo make install
