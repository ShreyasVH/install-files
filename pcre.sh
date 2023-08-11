VERSION=10.42

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/pcre2" ]; then
	mkdir "$HOME/sources/pcre2"
fi

if [ ! -d "$HOME/programs/pcre2" ]; then
	mkdir "$HOME/programs/pcre2"
fi

if [ ! -d "$HOME/programs/pcre2/$VERSION" ]; then
	mkdir "$HOME/programs/pcre2/$VERSION"
fi

cd $HOME/sources/pcre2

make clean distclean

wget "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-"$VERSION"/pcre2-"$VERSION".tar.gz"
tar -xvf "pcre2-"$VERSION".tar.gz"
mv "pcre2-"$VERSION $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/pcre2/$VERSION
make
sudo make install