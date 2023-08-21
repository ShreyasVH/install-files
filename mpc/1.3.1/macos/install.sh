FOLDER_NAME=mpc
VERSION=1.3.1

GMP_FOLDER_NAME=gmp
GMP_VERSION=6.2.1

MPFR_FOLDER_NAME=mpfr
MPFR_VERSION=4.2.0


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

	bash ../../$GMP_FOLDER_NAME/$GMP_VERSION/macos/install.sh
	bash ../../$MPFR_FOLDER_NAME/$MPFR_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	wget "https://ftp.gnu.org/gnu/mpc/mpc-$VERSION.tar.gz"

	tar -xvf "mpc-$VERSION.tar.gz"
	mv "mpc-$VERSION" $VERSION
	cd $VERSION
	./configure --prefix="$HOME/programs/$FOLDER_NAME/$VERSION" --with-gmp=$HOME/programs/$GMP_FOLDER_NAME/$GMP_VERSION --with-mpfr=$HOME/programs/$MPFR_FOLDER_NAME/$MPFR_VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "mpc-$VERSION.tar.gz"
fi

cd $HOME/install-files