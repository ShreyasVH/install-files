version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)

program_dir=$(dirname "$version_dir")
FOLDER_NAME=$(basename $program_dir)

os_dir=$(dirname $program_dir)
OS=$(basename $os_dir)

DEPTH=1
if [ $# -ge 1 ]; then
    DEPTH=$1
fi

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/logstash.yml ]; then
	printf "logstash.yml not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/logstash" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	LINK="$(get_protocol_for_binary "https")://$(get_domain_for_binary "artifacts.elastic.co")/downloads/logstash/logstash-$VERSION-darwin-x86_64.tar.gz"
	ARCHIVE_FILE="$(basename ${LINK})"
	start_time=$(date +%s)
	start_time_total=$(date +%s)
	download_binary "${FOLDER_NAME}" "${VERSION}" "${LINK}" "wget" "${DEPTH}"
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	tar -xf $ARCHIVE_FILE
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	mv "logstash-$VERSION" $VERSION
	cd $VERSION

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	touch .envrc
	echo "export PATH=\$HOME/programs/$FOLDER_NAME/$VERSION/bin:\$PATH" >> .envrc
	echo "" >> .envrc
	direnv allow

	mv config/logstash.yml ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/logstash.yml.default
	cp $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/logstash.yml config/logstash.yml
	cp $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/logstash.conf config/logstash.conf

	touch start.sh
	echo 'PORT=$(grep '\''api.http.port: '\'' config/logstash.yml | awk '\''{print $2}'\'')' >> start.sh
	echo 'PID_FILE=logstash.pid' >> start.sh
	echo '' >> start.sh
	echo 'if [ ! -e ${PID_FILE} ]; then' >> start.sh
	echo -e '\techo "Starting"' >> start.sh
	echo -e "\tlogstash -f config/logstash.conf > logstash.log 2>&1 &" >> start.sh
	echo -e "\tPID=\$!" >> start.sh
	echo -e "\techo \${PID} > \${PID_FILE}" >> start.sh
	echo 'fi' >> start.sh

	touch stop.sh
	echo 'PORT=$(grep '\''api.http.port: '\'' config/logstash.yml | awk '\''{print $2}'\'')' >> stop.sh
	echo 'PID_FILE=logstash.pid' >> stop.sh
	echo '' >> stop.sh
	echo 'if [ -e ${PID_FILE} ]; then' >> stop.sh
	echo -e '\techo "Stopping"' >> stop.sh
	echo -e '\tkill -9 $(cat ${PID_FILE})' >> stop.sh
	echo -e '\trm ${PID_FILE}' >> stop.sh
	echo 'fi' >> stop.sh

	VERSION_STRING=$(echo "$VERSION" | sed 's/\./_/g')
	DOMAIN_NAME=logstash_$VERSION_STRING.local.com
	if ! grep -q "$DOMAIN_NAME" /etc/hosts; then
	    SUDO_ASKPASS=$HOME/askpass.sh sudo -A sh -c "echo '127.0.0.1 ' $DOMAIN_NAME >> /etc/hosts"
	fi

	bash $INSTALL_FILES_DIR/clearBinary.sh $ARCHIVE_FILE $((DEPTH))

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi