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

download_binary () {
	local FOLDER_NAME=$1
	local VERSION=$2
	local TYPE=$4
	local URL=$3
	local DEPTH=$5

	MAX_RETRIES=10
	RETRY_DELAY=5

	if [[ "${TYPE}" = "wget" ]]; then
		for ((i = 1; i <= MAX_RETRIES; i++)); do
    		wget --show-progress \
	         -c \
	         --timeout=30 \
	         --retry-connrefused \
	         "$URL" \
	         > "$HOME/logs/$FOLDER_NAME/$VERSION/download.txt" 2>&1 && break

		    if (( i < MAX_RETRIES )); then
		        print_message "${bold}${red}Download failed. Retrying in ${RETRY_DELAY}s... ($i/$MAX_RETRIES)${clear}" ${DEPTH}
		        sleep "$RETRY_DELAY"
		    else
		        echo "Download failed after $MAX_RETRIES attempts."
		        return 1   # or exit 1
		    fi
		done
	elif [[ "${TYPE}" = "curl" ]]; then
		curl -fL --retry 10 --retry-delay 5 --retry-all-errors --connect-timeout 30 -C - -O  "${URL}" > $HOME/logs/${FOLDER_NAME}/${VERSION}/download.txt 2>&1
	fi
}