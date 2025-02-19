FOLDER_NAME=unixodbc
VERSION=2.3.11

DEPTH=1
if [ $# -ge 1 ]; then
    DEPTH=$1
fi

ODBC_FOLDER_NAME=odbc
ODBC_VERSION=18.4.1.1

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/isql" ]; then
	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH+1))
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$ODBC_FOLDER_NAME/$ODBC_VERSION/macos/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH+2))
	ARCHIVE_FILE="unixODBC-$VERSION.tar.gz"
	wget -q "https://www.unixodbc.org/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH+2))
	tar -xf $ARCHIVE_FILE
	mv "unixODBC-$VERSION" $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH+2))
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH+2))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/isql" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

		odbcinst -i -d -f $HOME/programs/$ODBC_FOLDER_NAME/$ODBC_VERSION/odbcinst.ini > /dev/null 2>&1
		sed -i '' "s|/opt/homebrew|$HOME/programs/odbc/$ODBC_VERSION|" etc/odbcinst.ini

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi