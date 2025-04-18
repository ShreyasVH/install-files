#!/bin/bash

if [ $# -lt 1 ]; then
    printf "${bold}${red}Usage: $0 <program_name>${clear}\n"
    exit 1
fi

MAC_FOLDER=$INSTALL_FILES_DIR"/"$OS_FOLDER
FOLDER=$MAC_FOLDER"/"$1

failed_versions=()

path_to_check=$(cat "programData.json" | jq -r --arg folder $1 '.[$folder].path')

for version_dir in "$FOLDER"/*/; do
  if [ -d "$version_dir" ]; then
    version=$(basename $version_dir)

    bash $MAC_FOLDER/$1/$version/install.sh 2

    if [ ! -e "$HOME/programs/$1/$version"$path_to_check ]; then
        failed_versions+=("$version")
    fi
  fi
done

printf "Failed versions:\n"
for element in "${failed_versions[@]}"; do
    printf "${bold}${red}$element${clear}\n"
done
