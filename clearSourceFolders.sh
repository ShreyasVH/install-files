if [ $# -lt 3 ]; then
    printf "${bold}${red}Usage: $0 <FOLDER_NAME> <VERSION> <ARCHIVE_FILE>${clear}"
    exit 1
fi

FOLDER_NAME=$1
VERSION=$2
ARCHIVE_FILE=$3
DEPTH=$4

source $INSTALL_FILES_DIR/utils.sh

print_message "${bold}${green}Clearing${clear}" $DEPTH
cd $HOME/sources/$FOLDER_NAME
SUDO_ASKPASS=$HOME/askpass.sh sudo -A rm -rf $VERSION
SUDO_ASKPASS=$HOME/askpass.sh sudo -A rm $ARCHIVE_FILE

if [ -e "$HOME/sources/$FOLDER_NAME/.DS_Store" ]; then
	SUDO_ASKPASS=$HOME/askpass.sh sudo -A rm "$HOME/sources/$FOLDER_NAME/.DS_Store"
fi

if [ -d $HOME/sources/$FOLDER_NAME ] && [ $(ls -A "$HOME/sources/$FOLDER_NAME" | wc -l) -eq 0 ]; then
	cd ..
	SUDO_ASKPASS=$HOME/askpass.sh sudo -A rm -rf $HOME/sources/$FOLDER_NAME
fi