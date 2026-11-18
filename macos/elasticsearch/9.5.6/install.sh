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

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/elasticsearch.yml ]; then
	printf "elasticsearch.yml not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/elasticsearch" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	LINK="$(get_protocol_for_binary "https")://$(get_domain_for_binary "artifacts.elastic.co")/downloads/elasticsearch/elasticsearch-$VERSION-darwin-aarch64.tar.gz"
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
	
	mv "elasticsearch-$VERSION" $VERSION
	cd $VERSION

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

	touch start.sh
	echo 'PORT=$(grep '\''http.port: '\'' config/elasticsearch.yml | awk '\''{print $2}'\'')' >> start.sh
	echo '' >> start.sh
	echo 'if [ ! -e elastic.pid ]; then' >> start.sh
	echo -e '\techo "Starting"' >> start.sh
	echo -e "\telasticsearch -d -p elastic.pid > elastic.log 2>&1 &" >> start.sh
	echo 'fi' >> start.sh

	touch stop.sh
	mv config/elasticsearch.yml $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/elasticsearch.yml.default
	ln -s $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/elasticsearch.yml config/elasticsearch.yml
	echo 'PORT=$(grep '\''http.port: '\'' config/elasticsearch.yml | awk '\''{print $2}'\'')' >> stop.sh
	echo '' >> stop.sh
	echo 'if [ -e elastic.pid ]; then' >> stop.sh
	echo -e '\techo "Stopping"' >> stop.sh
	echo -e '\tkill -9 $(cat elastic.pid)' >> stop.sh
	echo -e '\trm elastic.pid' >> stop.sh
	echo 'fi' >> stop.sh

	PORT=$(grep 'http.port: ' config/elasticsearch.yml | awk '{print $2}')

	cp $HOME/workspace/myProjects/ssl/server.crt config
	cp $HOME/workspace/myProjects/ssl/server.key config
	cp $HOME/workspace/myProjects/ssl/rootCA.crt config
	
	start_time=$(date +%s)
	bash start.sh > /dev/null 2>&1
	print_message "${bold}${green}Waiting for elasticsearch to start${clear}" $((DEPTH))
	print_message "" $((DEPTH)) "Y"
	while [[ ! $(lsof -i:$PORT -t | wc -l) -gt 0 ]];
	do
	    printf "."
	    sleep 1
	done
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	print_message "${bold}${green}Waiting for elasticsearch to be stable${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	MAX_RETRIES=120
	RETRY=0

	until curl -ks "https://localhost:$PORT/" >/dev/null 2>&1; do
	    sleep 1
	    RETRY=$((RETRY + 1))

	    if [ "$RETRY" -ge "$MAX_RETRIES" ]; then
	        echo "Elasticsearch failed to start"
	        tail -100 elastic.log
	        exit 1
	    fi

	    printf "."
	done
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	print_message "${bold}${green}Setting default password${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	./bin/elasticsearch-setup-passwords auto --batch --url "https://localhost:$PORT" > es_passwords.txt
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	ELASTIC_PASSWORD=$(grep 'PASSWORD elastic =' es_passwords.txt | awk '{print $4}')
	KIBANA_PASSWORD=$(grep 'PASSWORD kibana =' es_passwords.txt | awk '{print $4}')
	PASSWORD="password"

	print_message "${bold}${green}Setting password${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	curl -X POST "https://localhost:$PORT/_security/user/elastic/_password" -u "elastic:$ELASTIC_PASSWORD" -H "Content-Type: application/json" -k -d "{\"password\":\"$PASSWORD\"}" > $HOME/logs/setPassword.txt 2>&1

	curl -X POST "https://localhost:$PORT/_security/user/kibana_system/_password" -u "elastic:$PASSWORD" -H "Content-Type: application/json" -k -d "{\"password\":\"$PASSWORD\"}" >> $HOME/logs/setPassword.txt 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	bash stop.sh > /dev/null 2>&1

	VERSION_STRING=$(echo "$VERSION" | sed 's/\./-/g')
	DOMAIN_NAME=elastic-$VERSION_STRING.local.com
	if ! grep -q "$DOMAIN_NAME" /etc/hosts; then
	    SUDO_ASKPASS=$HOME/askpass.sh sudo -A sh -c "echo '127.0.0.1 ' $DOMAIN_NAME >> /etc/hosts"
	fi

	bash $INSTALL_FILES_DIR/clearBinary.sh $ARCHIVE_FILE $((DEPTH))

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi

