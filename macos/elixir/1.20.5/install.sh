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

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

ERLANG_FOLDER_NAME=erlang
ERLANG_VERSION=$(jq -r --arg folder "${ERLANG_FOLDER_NAME}" '.[$folder]' latestVersions.json)

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/elixir" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$ERLANG_FOLDER_NAME/$ERLANG_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$ERLANG_FOLDER_NAME/$ERLANG_VERSION/bin:$PATH

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	start_time_total=$(date +%s)
	git clone --branch "v${VERSION}" https://github.com/elixir-lang/elixir.git > $HOME/logs/${FOLDER_NAME}/${VERSION}/download.txt 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	mv elixir "${VERSION}"
	cd "${VERSION}"
	
	print_message "${bold}${green}Making${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	make -j$PROCESS_COUNT > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	print_message "${bold}${green}Installing${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	SUDO_ASKPASS=$HOME/askpass.sh sudo -A make install PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/elixir" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$ERLANG_FOLDER_NAME/$ERLANG_VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION "" $((DEPTH))
	fi

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi

