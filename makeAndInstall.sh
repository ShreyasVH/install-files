if [ $# -lt 2 ]; then
    printf "${bold}${red}Usage: $0 <FOLDER_NAME> <VERSION>${clear}"
    exit 1
fi

FOLDER_NAME=$1
VERSION=$2

DEPTH=2
if [ $# -ge 3 ]; then
    DEPTH=$3
fi

bash $INSTALL_FILES_DIR/make.sh $FOLDER_NAME $VERSION $DEPTH
bash $INSTALL_FILES_DIR/install.sh $FOLDER_NAME $VERSION $DEPTH