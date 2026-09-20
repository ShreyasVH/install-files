print_message () {
	local MESSAGE=$1
	local DEPTH=$2

	for i in $(seq 2 $DEPTH); do
		printf "\t"
	done

	# printf "%s\n" "$MESSAGE"
	printf "${MESSAGE}\n"
}

resolve_dependency_version () {
	local FOLDER_NAME=$1
	local VERSION=$2
	local OS=$3
	local DEPENDENCY=$4

	jq -sr \
        --arg folder "$FOLDER_NAME" \
        --arg version "$VERSION" \
        --arg os "$OS" \
        --arg dependency "$DEPENDENCY" \
        '
        (
            (.[0][$folder][$version] // {})
            * (.[1][$folder][$version] // {})
            * (.[1][$os][$folder][$version] // {})
        )[$dependency] // empty
        ' \
        versionMap.json staticVersionMap.json
}
