if [ $# -lt 2 ]; then
    printf "${bold}${red}Usage: $0 <FOLDER_NAME> <VERSION>${clear}"
    exit 1
fi

FOLDER_NAME=$1
VERSION=$2

bash $INSTALL_FILES_DIR/make.sh $FOLDER_NAME $VERSION
bash $INSTALL_FILES_DIR/install.sh $FOLDER_NAME $VERSION