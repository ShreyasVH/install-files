VERSION=1.0.18
FOLDER_NAME=libmemcached
MINOR_VERSION=1.0

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

	cd "$HOME/sources/$FOLDER_NAME"

	printf "${bold}${yellow}Installing $FOLDER_NAME${clear}\n"

	printf "\t${bold}${blink}${green}Downloading source code${clear}\n"
	wget -q "https://launchpad.net/libmemcached/$MINOR_VERSION/$VERSION/+download/libmemcached-$VERSION.tar.gz"
	printf "\t${bold}${blink}${green}Extracting source code${clear}\n"
	tar -xf "libmemcached-$VERSION.tar.gz"
	mv "libmemcached-$VERSION" $VERSION
	cd $VERSION
	printf "\t${bold}${blink}${green}Configuring${clear}\n"
	sed '/ac_cv_have_htonll/ {
  :start
  N
  /fi$/!b start
  s/if ac_fn_cxx_try_compile "$LINENO"; then :.*fi/ac_cv_have_htonll=no/
}' $HOME/sources/$FOLDER_NAME/$VERSION/configure > $HOME/sources/$FOLDER_NAME/$VERSION/configureCopy
	rm $HOME/sources/$FOLDER_NAME/$VERSION/configure
	mv $HOME/sources/$FOLDER_NAME/$VERSION/configureCopy $HOME/sources/$FOLDER_NAME/$VERSION/configure
	sudo chmod 755 $HOME/sources/$FOLDER_NAME/$VERSION/configure
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	sed -i '' 's/opt_servers == false/opt_servers == NULL/' $HOME/sources/$LIBMEMCACHED_FOLDER_NAME/$LIBMEMCACHED_VERSION/clients/memflush.cc
	printf "\t${bold}${blink}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${blink}${green}Installing${clear}\n"
	sudo make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/memflush" ]; then
		printf "\t${bold}${blink}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "libmemcached-$VERSION.tar.gz"
	fi
fi