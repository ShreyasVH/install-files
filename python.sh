VERSION=3.11.4
PKG_CONFIG_VERSION=0.29.2
GETTEXT_VERSION=0.22

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/python" ]; then
	mkdir "$HOME/sources/python"
fi

if [ ! -d "$HOME/programs/python" ]; then
	mkdir "$HOME/programs/python"
fi

if [ ! -d "$HOME/programs/python/$VERSION" ]; then
	mkdir "$HOME/programs/python/$VERSION"
fi

cd $HOME/sources/python

make clean distclean

export PATH="$HOME/programs/pkg-config/$PKG_CONFIG_VERSION/bin:$PATH"

export LDFLAGS="-L$HOME/programs/gettext/$GETTEXT_VERSION/lib"
export CPPFLAGS="-I$HOME/programs/gettext/$GETTEXT_VERSION/include"

wget "https://www.python.org/ftp/python/"$VERSION"/Python-"$VERSION".tgz"
tar -xvf "Python-"$VERSION".tgz"
mv "Python-"$VERSION $VERSION
cd $VERSION
./configure --with-pydebug --prefix="$HOME/programs/python/$VERSION"
make -s -j2
sudo make install
