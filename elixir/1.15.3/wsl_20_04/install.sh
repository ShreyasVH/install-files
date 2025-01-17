FOLDER_NAME=elixir
VERSION=1.15.4

cd $INSTALL_FILES_DIR

ERLANG_FOLDER_NAME=erlang
ERLANG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ERLANG_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/elixir" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	bash $INSTALL_FILES_DIR/$ERLANG_FOLDER_NAME/$ERLANG_VERSION/wsl_20_04/install.sh

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$ERLANG_FOLDER_NAME/$ERLANG_VERSION/bin:$PATH

	printf "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	git clone -q https://github.com/elixir-lang/elixir.git
	cd elixir
	git checkout -q "v"$VERSION
	printf "\t${bold}${green}Making${clear}\n"
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	printf "\t${bold}${green}Installing${clear}\n"
	echo $USER_PASSWORD | sudo -S -p "" env "PATH=$PATH" make install PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/elixir" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$ERLANG_FOLDER_NAME/$ERLANG_VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		printf "\t${bold}${green}Clearing${clear}\n"
		cd $HOME/sources/$FOLDER_NAME
		rm -rf elixir

		if [ -e "$HOME/sources/$FOLDER_NAME/.DS_Store" ]; then
			rm "$HOME/sources/$FOLDER_NAME/.DS_Store"
		fi

		if [ -d $HOME/sources/$FOLDER_NAME ] && [ $(ls -A "$HOME/sources/$FOLDER_NAME" | wc -l) -eq 0 ]; then
			cd ..
			rm -rf $HOME/sources/$FOLDER_NAME
		fi
	fi
fi

cd $HOME/install-files