#!/bin/bash

if [ $# -lt 1 ]; then
    printf "${bold}${red}Usage: $0 <program_name> <referenve_version>${clear}\n"
    exit 1
fi

if [ $# -lt 2 ]; then
    printf "${bold}${red}Usage: $0 <program_name> <referenve_version>${clear}\n"
    exit 1
fi

OS_FOLDER_FULL=$INSTALL_FILES_DIR"/"$OS_FOLDER
FOLDER=$OS_FOLDER_FULL"/"$1
REFERENCE_PROGRAM_FOLDER=$INSTALL_FILES_DIR"/"$1
REFERENCE_OS_FOLDER=$REFERENCE_PROGRAM_FOLDER"/"$OS_FOLDER

REFERENCE_VERSION=$2

REFERENCE_INSTALL_FILE=$FOLDER"/"$REFERENCE_VERSION"/install.sh"
ls $REFERENCE_INSTALL_FILE

for version_dir in "$REFERENCE_PROGRAM_FOLDER"/*/; do
  if [ -d "$version_dir" ]; then
    version=$(basename $version_dir)

    if [[ "$version" != "$REFERENCE_VERSION" ]]; then
        echo $version

        DESTINATION_FOLDER=$FOLDER"/"$version
        mkdir -p $DESTINATION_FOLDER
        cp $REFERENCE_INSTALL_FILE $DESTINATION_FOLDER"/"

        CONFIG_FOLDER_REFERENCE="$HOME/workspace/myProjects/config-samples/$1/$version/$OS_FOLDER"
        if [ -d "$CONFIG_FOLDER_REFERENCE" ]; then
            DESTINATION_CONFIG_FOLDER="$HOME/workspace/myProjects/config-samples/$OS_FOLDER/$1/$version"
            mkdir -p $DESTINATION_CONFIG_FOLDER
            cp $CONFIG_FOLDER_REFERENCE/* $DESTINATION_CONFIG_FOLDER/
        fi
    fi
  fi
done

