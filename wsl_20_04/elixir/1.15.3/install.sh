version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)

program_dir=$(dirname "$version_dir")
FOLDER_NAME=$(basename $program_dir)

os_dir=$(dirname $program_dir)
OS=$(basename $os_dir)

DEPTH=1
if [ $# -ge 1 ]; then
    DEPTH=$1
fi

ERLANG_FOLDER_NAME=erlang
ERLANG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$ERLANG_FOLDER_NAME" '.[$folder][$version][$name]')

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/elixir" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing $FOLDER_NAME $VERSION${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$ERLANG_FOLDER_NAME/$ERLANG_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$ERLANG_FOLDER_NAME/$ERLANG_VERSION/bin:$PATH

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	git clone -q https://github.com/elixir-lang/elixir.git
	cd elixir
	git checkout -q "v"$VERSION
	print_message "${bold}${green}Making${clear}" $((DEPTH))
	make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	print_message "${bold}${green}Installing${clear}" $((DEPTH))
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

		print_message "${bold}${green}Clearing${clear}" $((DEPTH))
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