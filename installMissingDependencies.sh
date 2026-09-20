PROGRAM=$1
VERSION=$2

DEPTH=3
if [ $# -ge 3 ]; then
    DEPTH=$3
fi

MISSING_DEPENDENCIES=$(node getMissingInstallFiles.js $1 $2)



echo "$MISSING_DEPENDENCIES" | jq -r 'to_entries[] | .key as $k | .value[] | "\($k)|\(.)"' |
while IFS='|' read -r dependencyProgram dependencyVersion; do
    if jq -e --arg key "$dependencyProgram" 'has($key)' programData.json > /dev/null; then
        # echo "Key exists: ${dependencyProgram}"

        zsh installMissingDependencies.sh ${dependencyProgram} ${dependencyVersion} $((DEPTH + 1))

        if [[ -f "./src/upgrades/${dependencyProgram}.js" ]]; then
        	# echo $dependencyProgram
            node ./src/upgrades/${dependencyProgram}.js ${dependencyVersion}
            zsh ${OS_FOLDER}/${dependencyProgram}/${dependencyVersion}/install.sh $((DEPTH))
        else
            # echo "base"
        	node ./src/upgrades/base.js ${dependencyProgram} ${dependencyVersion}
        	zsh ${OS_FOLDER}/${dependencyProgram}/${dependencyVersion}/install.sh $((DEPTH))
        fi
    fi

done