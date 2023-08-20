FOLDER_NAME=cmake
VERSION=3.26.3

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

if [ ! -d "$HOME/programs/$BOOST_FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$BOOST_FOLDER_NAME"
fi

cd $HOME/sources/$FOLDER_NAME

wget "https://github.com/Kitware/CMake/releases/download/v$VERSION/cmake-$VERSION.tar.gz"
tar -xvf "cmake-$VERSION.tar.gz"
mv "cmake-"$VERSION $VERSION
cd $VERSION
./bootstrap --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
make
sudo make install

cd $HOME/programs/$FOLDER_NAME/$VERSION
sudo chown -R $(whoami) .

cd $HOME/sources/$FOLDER_NAME
rm -rf $VERSION
rm "cmake-$VERSION.tar.gz"