VERSION=1.0.18
FOLDER_NAME=libmemcached
MINOR_VERSION=1.0

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/memflush" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	cd "$HOME/sources/$FOLDER_NAME"

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="libmemcached-$VERSION.tar.gz"
	wget -q --show-progress "https://launchpad.net/libmemcached/$MINOR_VERSION/$VERSION/+download/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "libmemcached-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	sed '/ac_cv_have_htonll/ {
  :start
  N
  /fi$/!b start
  s/if ac_fn_cxx_try_compile "$LINENO"; then :.*fi/ac_cv_have_htonll=no/
}' $HOME/sources/$FOLDER_NAME/$VERSION/configure > $HOME/sources/$FOLDER_NAME/$VERSION/configureCopy
	rm $HOME/sources/$FOLDER_NAME/$VERSION/configure
	mv $HOME/sources/$FOLDER_NAME/$VERSION/configureCopy $HOME/sources/$FOLDER_NAME/$VERSION/configure
	echo $USER_PASSWORD | sudo -S -p "" chmod 755 $HOME/sources/$FOLDER_NAME/$VERSION/configure
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	sed -i '' 's/opt_servers == false/opt_servers == NULL/' $HOME/sources/$FOLDER_NAME/$VERSION/clients/memflush.cc
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/memflush" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi