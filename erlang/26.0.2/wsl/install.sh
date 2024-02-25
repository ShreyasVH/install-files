FOLDER_NAME=erlang
VERSION=26.0.2

PERL_VERSION=5.38.0
FOLDER_NAME_PERL=perl

FOLDER_NAME_OPENSSL=openssl
OPENSSL_VERSION=3.0.10

NCURSES_FOLDER_NAME=ncurses
NCURSES_VERSION=6.4

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/erl" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$FOLDER_NAME_PERL/$PERL_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$FOLDER_NAME_OPENSSL/$OPENSSL_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/wsl/install.sh

	export CPPFLAGS="-I$HOME/programs/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/include/ncurses -I$HOME/programs/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/include"
	export LDFLAGS="-L$HOME/programs/$NCURSES_FOLDER_NAME/$NCURSES_VERSION/lib"

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$FOLDER_NAME_PERL/$PERL_VERSION/bin:$PATH

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	ARCHIVE_FILE="otp_src_$VERSION.tar.gz"
	wget -q --show-progress "https://github.com/erlang/otp/releases/download/OTP-$VERSION/$ARCHIVE_FILE"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf $ARCHIVE_FILE
	mv "otp_src_$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-ssl=$HOME/programs/$FOLDER_NAME_OPENSSL/$OPENSSL_VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/erl" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE
	fi
fi

cd $HOME/install-files