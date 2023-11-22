FOLDER_NAME=perl
VERSION=5.39.3
MINOR_VERSION=5.0

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

	cd $HOME/sources/$FOLDER_NAME

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://www.cpan.org/src/$MINOR_VERSION/perl-$VERSION.tar.gz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "perl-$VERSION.tar.gz"
	mv "perl-$VERSION" $VERSION
	cd $VERSION
	echo $USER_PASSWORD | sudo -S -p "" chmod 755 $HOME/sources/$FOLDER_NAME/$VERSION/configure
	./Configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./Configure -des -Dprefix=$HOME/programs/$FOLDER_NAME/$VERSION -Dusedevel > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	printf "\t${bold}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S -p "" make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/perl$VERSION" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .
		ln -s $HOME/programs/$FOLDER_NAME/$VERSION/bin/perl$VERSION bin/perl

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf $VERSION
		rm "perl-$VERSION.tar.gz"
	fi
fi

cd $HOME/install-files