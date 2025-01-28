if [ $# -lt 2 ]; then
    printf "${bold}${red}Usage: $0 <FOLDER_NAME> <VERSION>${clear}"
    exit 1
fi

FOLDER_NAME=$1
VERSION=$2
DEPTH=$3

source $INSTALL_FILES_DIR/utils.sh

print_message "${bold}${green}Making${clear}" $DEPTH
make > $HOME/logs/$FOLDER_NAME/$VERSION/makeOutput.txt 2>&1