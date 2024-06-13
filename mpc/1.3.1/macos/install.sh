FOLDER_NAME=mpc
VERSION=1.3.1

cd $INSTALL_FILES_DIR

GMP_FOLDER_NAME=gmp
GMP_VERSION=6.2.1

MPFR_FOLDER_NAME=mpfr
MPFR_VERSION=4.2.0

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libmpc.dylib" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$GMP_FOLDER_NAME/$GMP_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$MPFR_FOLDER_NAME/$MPFR_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="mpc-$VERSION.tar.gz"
	LINK="https://ftp.gnu.org/gnu/mpc/$ARCHIVE_FILE"
	wget -q --show-progress $LINK
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "mpc-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-gmp=$HOME/programs/$GMP_FOLDER_NAME/$GMP_VERSION --with-mpfr=$HOME/programs/$MPFR_FOLDER_NAME/$MPFR_VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libmpc.dylib" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files