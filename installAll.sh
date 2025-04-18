#!/bin/bash

FOLDER=$INSTALL_FILES_DIR"/"$OS_FOLDER

for program_dir in "$FOLDER"/*/; do
  if [ -d "$program_dir" ]; then
    program=$(basename "$program_dir")
    echo $program
    for version_dir in "$program_dir"*/; do
      if [ -d "$version_dir" ]; then
        version=$(basename "$version_dir")
        printf "\t$version\n"
      fi
    done
  fi
done
