VERSION=1.10.2
FOLDER_NAME=libgcrypt

cd $INSTALL_FILES_DIR

LIBGPG_ERROR_FOLDER_NAME=libgpg-error
LIBGPG_ERROR_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$LIBGPG_ERROR_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/libgcrypt-config" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$LIBGPG_ERROR_FOLDER_NAME/$LIBGPG_ERROR_VERSION/macos/install.sh

	cd "$HOME/sources/$FOLDER_NAME"

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="libgcrypt-$VERSION.tar.bz2"
	wget -q --show-progress "https://www.gnupg.org/ftp/gcrypt/libgcrypt/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "libgcrypt-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --host=aarch64-apple-darwin --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --disable-dev-random --with-libgpg-error-prefix=$HOME/programs/$LIBGPG_ERROR_FOLDER_NAME/$LIBGPG_ERROR_VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	sed -i '' 's/fips_mode ()/0 \&\& fips_mode ()/' $HOME/sources/$FOLDER_NAME/$VERSION/random/rndgetentropy.c
	sed -i '' 's/ret = getrandom (buffer, nbytes, GRND_RANDOM);//' $HOME/sources/$FOLDER_NAME/$VERSION/random/rndgetentropy.c
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/libgcrypt-config" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi