FOLDER_NAME=perl
VERSION=5.38.0
MINOR_VERSION=5.0

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

wget "https://www.cpan.org/src/$MINOR_VERSION/perl-$VERSION.tar.gz"
tar -xvf "perl-$VERSION.tar.gz"
mv "perl-$VERSION" $VERSION
cd $VERSION
./Configure -des -Dprefix=$HOME/programs/$FOLDER_NAME/$VERSION
make
sudo make install