if [ $# -lt 2 ]; then
    printf "${bold}${red}Usage: $0 <ARCHIVE_FILE>${clear}"
    exit 1
fi

ARCHIVE_FILE=$1
DEPTH=$2

source $INSTALL_FILES_DIR/utils.sh

print_message "${bold}${green}Clearing${clear}" $DEPTH "Y"
start_time=$(date +%s)
cd ..
SUDO_ASKPASS=$HOME/askpass.sh sudo -A rm $ARCHIVE_FILE
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
print_message " - ${elapsed}s" 2