VERSION=4.4.1
FOLDER_NAME=make

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/make" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	echo $USER_PASSWORD | sudo -S -p '' ln -s /usr/bin/sed /usr/local/binaries/sed
	echo $USER_PASSWORD | sudo -S -p '' ln -s /usr/bin/make /usr/local/binaries/make
	echo $USER_PASSWORD | sudo -S -p '' ln -s /usr/bin/tar /usr/local/binaries/tar
	echo $USER_PASSWORD | sudo -S -p '' ln -s /usr/bin/perl /usr/local/binaries/perl
	export CC=/usr/bin/gcc
	which sed

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	# printf "\t${bold}${green}Downloading source code${clear}\n"
	# ARCHIVE_FILE="make-$VERSION.tar.gz"
	# wget -q --show-progress "https://ftp.gnu.org/gnu/make/$ARCHIVE_FILE"
	# printf "\t${bold}${green}Extracting source code${clear}\n"
	# tar -xf $ARCHIVE_FILE
	# mv "make-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/make" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi

	echo $USER_PASSWORD | sudo -S -p '' rm /usr/local/binaries/sed
	echo $USER_PASSWORD | sudo -S -p '' rm /usr/local/binaries/make
	echo $USER_PASSWORD | sudo -S -p '' rm /usr/local/binaries/tar
	echo $USER_PASSWORD | sudo -S -p '' rm /usr/local/binaries/perl
fi

cd $HOME/install-files
