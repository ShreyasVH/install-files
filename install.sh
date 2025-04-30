if [ $# -lt 2 ]; then
    printf "${bold}${red}Usage: $0 <FOLDER_NAME> <VERSION>${clear}"
    exit 1
fi

FOLDER_NAME=$1
VERSION=$2
DEPTH=$3

source $INSTALL_FILES_DIR/utils.sh

print_message "${bold}${green}Installing${clear}" $DEPTH
SUDO_ASKPASS=$HOME/askpass.sh sudo -A LD_LIBRARY_PATH="$LD_LIBRARY_PATH" LD_RUN_PATH="$LD_RUN_PATH" make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1