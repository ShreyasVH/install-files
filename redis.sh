FOLDER_NAME=redis
VERSION=7.0.12

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

wget "https://github.com/redis/redis/archive/$VERSION.tar.gz"
tar -xvf "$VERSION.tar.gz"
mv "redis-$VERSION" $VERSION
cd $VERSION
make
sudo PREFIX=$HOME/programs/redis/$VERSION make install
export PATH="$HOME/programs/redis/$VERSION/bin:$PATH"
