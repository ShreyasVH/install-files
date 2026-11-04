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

PHP_FOLDER_NAME=php
PHP_VERSION=8.2.14

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/config.inc.php ]; then
	print_message "config.inc.php not found" $((DEPTH))
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/index.php" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$PHP_FOLDER_NAME/$PHP_VERSION/install.sh $((DEPTH+1))

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	LINK="$(get_protocol_for_binary "https")://$(get_domain_for_binary "files.phpmyadmin.net")/phpMyAdmin/$VERSION/phpMyAdmin-$VERSION-all-languages.zip"
	ARCHIVE_FILE="$(basename ${LINK})"
	start_time=$(date +%s)
	start_time_total=$(date +%s)
	download_binary "${FOLDER_NAME}" "${VERSION}" "${LINK}" "wget" "${DEPTH}"
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	unzip $ARCHIVE_FILE > /dev/null 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	mv "phpMyAdmin-$VERSION-all-languages" $VERSION
	cd $VERSION

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$PHP_FOLDER_NAME/$PHP_VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	touch start.sh
	PORT=9100
	echo "if ! lsof -i :$PORT > /dev/null; then" >> start.sh
	echo -e '\techo "Starting"' >> start.sh
	echo -e "\tphp -S '0.0.0.0:$PORT' -t . > phpmyadmin.log 2>&1 &" >> start.sh
	echo "fi" >> start.sh

	touch stop.sh
	echo "if lsof -i :$PORT > /dev/null; then" >> stop.sh
	echo -e '\techo "Stopping"' >> stop.sh
	echo -e '\tkill -9 $(lsof -t -i:'$PORT')' >> stop.sh
	echo "fi" >> stop.sh

	mv config.sample.inc.php ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/config.inc.php.default
	ln -s ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/config.inc.php ./

	bash $INSTALL_FILES_DIR/clearBinary.sh $ARCHIVE_FILE $((DEPTH))

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi