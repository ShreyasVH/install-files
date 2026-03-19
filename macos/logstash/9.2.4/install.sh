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

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="logstash-$VERSION-darwin-x86_64.tar.gz"
	wget --show-progress "https://artifacts.elastic.co/downloads/logstash/$ARCHIVE_FILE" > $HOME/logs/$FOLDER_NAME/$VERSION/download.txt 2>&1
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
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
	echo '' >> start.sh
	echo 'if ! lsof -i :$PORT > /dev/null; then' >> start.sh
	echo -e '\techo "Starting"' >> start.sh
	echo -e "\tlogstash -f config/logstash.conf > logstash.log 2>&1 &" >> start.sh
	echo 'fi' >> start.sh

	touch stop.sh
	echo 'PORT=$(grep '\''api.http.port: '\'' config/logstash.yml | awk '\''{print $2}'\'')' >> stop.sh
	echo '' >> stop.sh
	echo 'if lsof -i :$PORT > /dev/null; then' >> stop.sh
	echo -e '\techo "Stopping"' >> stop.sh
	echo -e '\tkill -9 $(lsof -t -i:$PORT)' >> stop.sh
	echo 'fi' >> stop.sh

	print_message "${bold}${green}Clearing${clear}" $((DEPTH))
	cd ..
	rm $ARCHIVE_FILE
fi