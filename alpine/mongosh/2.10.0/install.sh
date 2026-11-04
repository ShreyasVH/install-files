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

NODE_FOLDER_NAME=node
NODE_VERSION=$(jq -r --arg folder "${NODE_FOLDER_NAME}" '.[$folder]' latestVersions.json)

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mongosh" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$NODE_FOLDER_NAME/$NODE_VERSION/install.sh $((DEPTH+1))	

	export PATH=$HOME/programs/$NODE_FOLDER_NAME/$NODE_VERSION/bin:$PATH

	mkdir $VERSION
	cd $VERSION

	print_message "${bold}${green}Installing${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	start_time_total=$(date +%s)
	npm install mongosh@${VERSION} > $HOME/logs/$FOLDER_NAME/$VERSION/install.txt 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	mkdir bin
	ln -s $HOME/programs/$FOLDER_NAME/$VERSION/node_modules/mongosh/bin/mongosh.js $HOME/programs/$FOLDER_NAME/$VERSION/bin/mongosh
	
	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/mongosh" ]; then
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		touch .envrc
		echo "export PATH=\$HOME/programs/$NODE_FOLDER_NAME/$NODE_VERSION/bin:\$PATH" >> .envrc
		echo "export PATH=\$HOME/programs/$FOLDER_NAME/$VERSION/bin:\$PATH" >> .envrc
		echo "" >> .envrc
		direnv allow
	fi

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi

