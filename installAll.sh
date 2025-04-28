#!/bin/bash

failed_versions=()

SUDO_ASKPASS=$HOME/askpass.sh sudo -A rm -rf $HOME/sources

declare -A ignored_versions

ignored_versions["php_8.3.20"]=1
ignored_versions["php_8.4.5"]=1
ignored_versions["php_8.4.6"]=1

ignored_versions["m4_1.4.18"]=1

ignored_versions["postgis_3.3.2"]=1
ignored_versions["postgis_3.3.4"]=1
ignored_versions["postgis_3.4.0"]=1
ignored_versions["postgis_3.4.2"]=1
ignored_versions["postgis_3.4.3"]=1
ignored_versions["postgis_3.5.2"]=1

FOLDER=$INSTALL_FILES_DIR"/"$OS_FOLDER

for program_dir in "$FOLDER"/*/; do
  if [ -d "$program_dir" ]; then
    program=$(basename "$program_dir")
    echo $program

    path_to_check=$(cat "programData.json" | jq -r --arg folder $program '.[$folder].path')

    for version_dir in "$program_dir"*/; do
      if [ -d "$version_dir" ]; then
        version=$(basename "$version_dir")
        printf "\t$version\n"

        key="$program"_"$version"

        if [[ -z "${ignored_versions["$key"]}" ]]; then
          bash $FOLDER/$program/$version/install.sh 2

          if [ ! -e "$HOME/programs/$program/$version"$path_to_check ]; then
              failed_versions+=("$program-$version")
          fi
        fi
      fi
    done
  fi
done
