VERSION=0.22

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/gettext" ]; then
	mkdir "$HOME/sources/gettext"
fi

if [ ! -d "$HOME/programs/gettext" ]; then
	mkdir "$HOME/programs/gettext"
fi

if [ ! -d "$HOME/programs/gettext/$VERSION" ]; then
	mkdir "$HOME/programs/gettext/$VERSION"
fi

cd $HOME/sources/gettext

export CC=gcc
wget "https://ftp.gnu.org/gnu/gettext/gettext-$VERSION.tar.gz"
tar -xvf "gettext-$VERSION.tar.gz"
mv "gettext-$VERSION" $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/gettext/$VERSION
make
sudo make install
export PATH=$HOME/programs/gettext/$VERSION/bin:$PATH