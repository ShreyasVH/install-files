if [ $# -lt 2 ]; then
    printf "${bold}${red}Usage: $0 <FOLDER_NAME> <VERSION>${clear}"
    exit 1
fi

FOLDER_NAME=$1
VERSION=$2

printf "\t${bold}${green}Installing${clear}\n"
echo $USER_PASSWORD | sudo -S -p '' make install > $HOME/logs/$FOLDER_NAME/$VERSION/installOutput.txt 2>&1