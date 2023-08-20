FOLDER_NAME=bison
VERSION=3.8.2

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

wget "https://ftp.gnu.org/gnu/bison/bison-$VERSION.tar.gz"
tar -xvf "bison-$VERSION.tar.gz"
mv "bison-$VERSION" $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
make
sudo make install

cd $HOME/programs/$FOLDER_NAME/$VERSION
sudo chown -R $(whoami) .

cd $HOME/sources/$FOLDER_NAME
rm -rf $VERSION
rm "bison-$VERSION.tar.gz"