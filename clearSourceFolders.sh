if [ $# -lt 3 ]; then
    printf "${bold}${red}Usage: $0 <FOLDER_NAME> <VERSION> <ARCHIVE_FILE>${clear}"
    exit 1
fi

FOLDER_NAME=$1
VERSION=$2
ARCHIVE_FILE=$3

printf "\t${bold}${green}Clearing${clear}\n"
cd $HOME/sources/$FOLDER_NAME
rm -rf $VERSION
rm $ARCHIVE_FILE

if [ -e "$HOME/sources/$FOLDER_NAME/.DS_Store" ]; then
	rm "$HOME/sources/$FOLDER_NAME/.DS_Store"
fi

if [ -d $HOME/sources/$FOLDER_NAME ] && [ $(ls -A "$HOME/sources/$FOLDER_NAME" | wc -l) -eq 0 ]; then
	cd ..
	rm -rf $HOME/sources/$FOLDER_NAME
fi