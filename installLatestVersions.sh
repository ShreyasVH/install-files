for PROGRAM in $(cat latestVersions.json | jq -r 'keys[]'); do
  VERSION=$(cat latestVersions.json | jq -r --arg k "$PROGRAM" '.[$k]')
  
  IS_ENTRY_POINT=$(cat programData.json | jq -r --arg k "$PROGRAM" '.[$k].isEntryPoint // false')

  if [[ $IS_ENTRY_POINT = "true" && -f $OS_FOLDER/$PROGRAM/$VERSION/install.sh ]]; then
    zsh $OS_FOLDER/$PROGRAM/$VERSION/install.sh
  fi
done