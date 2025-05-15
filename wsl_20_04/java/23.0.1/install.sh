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

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/java" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 0

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE=bellsoft-jdk$VERSION+13-linux-amd64.tar.gz
	wget -q "https://github.com/bell-sw/Liberica/releases/download/$VERSION+13/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "jdk-$VERSION" $VERSION

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/java" ]; then
		cd $VERSION
		echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH
		keytool -import -alias dev-server -keystore lib/security/cacerts -file $HOME/workspace/myProjects/ssl/server.pem -storepass changeit -noprompt

		print_message "${bold}${green}Clearing${clear}" $((DEPTH))
		cd ..
		rm $ARCHIVE_FILE
	fi
fi
