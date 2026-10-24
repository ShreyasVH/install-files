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

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/usql" ]; then
  bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

  print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

  cd $HOME/programs/$FOLDER_NAME

  print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
  ARCHIVE_FILE="usql_static-${VERSION}-linux-amd64.tar.bz2"
  download_binary ${FOLDER_NAME} ${VERSION} "https://github.com/xo/usql/releases/download/v${VERSION}/$ARCHIVE_FILE" "wget" ${DEPTH}
  print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
  mkdir ${VERSION}
  tar -xf ${ARCHIVE_FILE} -C ${VERSION}
  cd $VERSION
  SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .
  SUDO_ASKPASS=$HOME/askpass.sh sudo -A ln -s $HOME/programs/${FOLDER_NAME}/${VERSION}/usql_static $HOME/programs/${FOLDER_NAME}/${VERSION}/usql

  touch .envrc
  echo "export PATH=\$HOME/programs/$FOLDER_NAME/$VERSION:\$PATH" >> .envrc
  direnv allow

  print_message "${bold}${green}Clearing${clear}" $((DEPTH))
  cd ..
  rm $ARCHIVE_FILE
fi

