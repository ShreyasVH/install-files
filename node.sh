VERSION=19.9.0

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/node" ]; then
	mkdir "$HOME/sources/node"
fi

if [ ! -d "$HOME/programs/node" ]; then
	mkdir "$HOME/programs/node"
fi

if [ ! -d "$HOME/programs/node/$VERSION" ]; then
	mkdir "$HOME/programs/node/$VERSION"
fi

cd $HOME/sources/node

make clean distclean

wget "https://nodejs.org/dist/v"$VERSION"/node-v"$VERSION".tar.gz"
tar -xvf "node-v"$VERSION".tar.gz"
mv "node-v"$VERSION $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/node/$VERSION
make
sudo make install
