version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)
MAJOR_VERSION=$(echo $VERSION | cut -d '.' -f 1)

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

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE=dotnet-sdk-$VERSION-linux-x64.tar.gz
	wget -q "https://builds.dotnet.microsoft.com/dotnet/Sdk/$VERSION/$ARCHIVE_FILE"
	mkdir $VERSION
	mv $ARCHIVE_FILE $VERSION/"dotnet-sdk-$VERSION-linux-x64.tar.gz"
	cd $VERSION
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE

	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow
	source .envrc

	print_message "${bold}${green}Installing dotnet ef${clear}" $((DEPTH))
	dotnet tool install --global dotnet-ef --version $MAJOR_VERSION".0.0" > $HOME/logs/$FOLDER_NAME/$VERSION/dotnetEfInstall.txt 2>&1

	print_message "${bold}${green}Clearing${clear}" $((DEPTH))
	rm $ARCHIVE_FILE
fi

cd $HOME/install-files