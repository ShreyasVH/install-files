VERSION=2.4.7
FOLDER_NAME=libtool

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

wget "https://ftp.gnu.org/gnu/libtool/libtool-$VERSION.tar.gz"
tar -xvf "libtool-$VERSION.tar.gz"
mv "libtool-"$VERSION $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
make
sudo make install