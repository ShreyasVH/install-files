print_message () {
	local MESSAGE=$1
	local DEPTH=$2

	for i in $(seq 1 $DEPTH); do
	    printf "\t"
	done

	printf "%s\n" "$MESSAGE"
}