VERSION=1.10.2
FOLDER_NAME=libgcrypt

LIBGPG_ERROR_FOLDER_NAME=libgpg-error
LIBGPG_ERROR_VERSION=1.47

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/logs" ]; then
	mkdir "$HOME/logs"
fi

if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
	mkdir "$HOME/sources/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/logs/$FOLDER_NAME/$VERSION"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	bash $INSTALL_FILES_DIR/$LIBGPG_ERROR_FOLDER_NAME/$LIBGPG_ERROR_VERSION/macos/install.sh

	cd "$HOME/sources/$FOLDER_NAME"

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q "https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-$VERSION.tar.bz2"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "libgcrypt-$VERSION.tar.bz2"
	mv "libgcrypt-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --host=aarch64-apple-darwin --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --disable-dev-random --with-libgpg-error-prefix=$HOME/programs/$LIBGPG_ERROR_FOLDER_NAME/$LIBGPG_ERROR_VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	sed -i '' 's/fips_mode ()/0 \&\& fips_mode ()/' $HOME/sources/$FOLDER_NAME/$VERSION/random/rndgetentropy.c
	sed -i '' 's/ret = getrandom (buffer, nbytes, GRND_RANDOM);//' $HOME/sources/$FOLDER_NAME/$VERSION/random/rndgetentropy.c
	printf "\t${bold}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	sudo make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/libgcrypt-config" ]; then
		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "libgcrypt-$VERSION.tar.bz2"
	fi
fi