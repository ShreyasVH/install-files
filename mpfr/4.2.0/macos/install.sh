FOLDER_NAME=mpfr
VERSION=4.2.0

GMP_FOLDER_NAME=gmp
GMP_VERSION=6.2.1

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

	bash ../../../$GMP_FOLDER_NAME/$GMP_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	wget "https://ftp.gnu.org/gnu/mpfr/mpfr-$VERSION.tar.gz"
	tar -xvf "mpfr-$VERSION.tar.gz"
	mv "mpfr-$VERSION" $VERSION
	cd $VERSION
	./configure --prefix="$HOME/programs/$FOLDER_NAME/$VERSION" --with-gmp=$HOME/programs/$GMP_FOLDER_NAME/$GMP_VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "mpfr-$VERSION.tar.gz"
fi

cd $HOME/install-files