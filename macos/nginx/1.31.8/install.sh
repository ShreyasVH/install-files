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

cd $INSTALL_FILES_DIR

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/nginx.conf ]; then
	print_message "${red}${bold}nginx.conf not found${clear}" $((DEPTH))
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/nginx" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	cd $HOME/sources/$FOLDER_NAME

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	LINK="$(get_protocol_for_binary "https")://$(get_domain_for_binary "nginx.org")/download/nginx-${VERSION}.tar.gz"
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
	
	mv "nginx-"$VERSION $VERSION
	cd $VERSION
	
	print_message "${bold}${green}Configuring${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/nginx/$VERSION --without-http_rewrite_module > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/sbin/nginx" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/sbin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		mv conf/nginx.conf ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/nginx.conf.default
		ln -s ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/nginx.conf conf/nginx.conf
		echo "<html><body><h1>It works! (version: $VERSION)</h1></body></html>" > html/index.html

		touch start.sh
		echo "nginx" >> start.sh

		touch stop.sh
		echo 'nginx -s stop' >> stop.sh

		VERSION_STRING=$(echo "$VERSION" | sed 's/\./_/g')
		DOMAIN_NAME=nginx_$VERSION_STRING.local.com
		if ! grep -q "$DOMAIN_NAME" /etc/hosts; then
		    SUDO_ASKPASS=$HOME/askpass.sh sudo -A sh -c "echo '127.0.0.1 ' $DOMAIN_NAME >> /etc/hosts"
		fi

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi