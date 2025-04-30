version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)
MAJOR_VERSION=$(echo $VERSION | cut -d '.' -f 1)
MINOR_VERSION=$(echo $VERSION | cut -d '.' -f 2)
VERSION_STRING=$MAJOR_VERSION"."$MINOR_VERSION

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

PKG_CONFIG_FOLDER_NAME=pkg-config
PKG_CONFIG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PKG_CONFIG_FOLDER_NAME" '.[$folder][$version][$name]')

PYTHON_FOLDER_NAME=python
PYTHON_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PYTHON_FOLDER_NAME" '.[$folder][$version][$name]')
# PYTHON_VERSION=3.11.3
PYTHON_MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -d '.' -f 1)
PYTHON_MINOR_VERSION=$(echo $PYTHON_VERSION | cut -d '.' -f 2)

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libxml2.so" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	export PATH=$HOME/programs/$PKG_CONFIG_FOLDER_NAME/$PKG_CONFIG_VERSION/bin:$PATH
	export PATH=$HOME/programs/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/bin:$PATH
	export PKG_CONFIG_PATH=$HOME/programs/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/lib/pkgconfig:$PKG_CONFIG_PATH
	export CPPFLAGS="-I$HOME/programs/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/include/python"$PYTHON_MAJOR_VERSION"."$PYTHON_MINOR_VERSION"d"

	export LD_RUN_PATH=$HOME/programs/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/lib:$LD_RUN_PATH
	export LD_LIBRARY_PATH=$HOME/programs/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/lib:$LD_LIBRARY_PATH

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="libxml2-$VERSION.tar.xz"
	wget -q "https://download.gnome.org/sources/libxml2/$VERSION_STRING/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "libxml2-$VERSION" $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION PYTHON=$HOME/programs/$PYTHON_FOLDER_NAME/$PYTHON_VERSION/bin/python3 > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/lib/libxml2.so" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi

cd $HOME/install-files