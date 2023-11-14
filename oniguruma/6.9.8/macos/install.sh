VERSION=6.9.8
FOLDER_NAME=oniguruma

AUTOCONF_VERSION=2.71
AUTOCONF_FOLDER_NAME=autoconf

AUTOMAKE_VERSION=1.16.5
AUTOMAKE_FOLDER_NAME=automake

LIBTOOL_VERSION=2.4.7
LIBTOOL_FOLDER_NAME=libtool

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

	bash $INSTALL_FILES_DIR/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$AUTOMAKE_FOLDER_NAME/$AUTOMAKE_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$LIBTOOL_FOLDER_NAME/$LIBTOOL_VERSION/macos/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$AUTOCONF_FOLDER_NAME/$AUTOCONF_VERSION/bin:$PATH
	export PATH=$HOME/programs/$AUTOMAKE_FOLDER_NAME/$AUTOMAKE_VERSION/bin:$PATH
	export PATH=$HOME/programs/$LIBTOOL_FOLDER_NAME/$LIBTOOL_VERSION/bin:$PATH
	export LIBTOOL=$HOME/programs/$LIBTOOL_FOLDER_NAME/$LIBTOOL_VERSION/bin/libtool

	printf "${bold}${yellow}Installing $FOLDER_NAME${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://github.com/kkos/oniguruma/releases/download/v$VERSION/onig-$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "onig-$VERSION.tar.gz"
	mv "onig-"$VERSION $VERSION
	cd $VERSION
	printf "\t${bold}${green}Running libtoolize${clear}\n"
	libtoolize > $HOME/logs/$FOLDER_NAME/$VERSION/libtoolOutput.txt 2>&1
	printf "\t${bold}${green}Running aclocal${clear}\n"
	aclocal > $HOME/logs/$FOLDER_NAME/$VERSION/aclocalOutput.txt 2>&1
	printf "\t${bold}${green}Running autoconf${clear}\n"
	autoconf > $HOME/logs/$FOLDER_NAME/$VERSION/autoconfOutput.txt 2>&1
	printf "\t${bold}${green}Running automake${clear}\n"
	automake --add-missing --copy > $HOME/logs/$FOLDER_NAME/$VERSION/automakeOutput.txt 2>&1
	printf "\t${bold}${green}Running autoreconf${clear}\n"
	autoreconf -vfi > $HOME/logs/$FOLDER_NAME/$VERSION/autoreconfOutput.txt 2>&1
	printf "\t${bold}${green}Configuring${clear}\n"
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	printf "\t${bold}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S -p '' make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/onig-config" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "onig-$VERSION.tar.gz"
	fi
fi

cd $HOME/install-files