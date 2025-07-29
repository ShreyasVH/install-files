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

APR_FOLDER_NAME=apr
APR_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$APR_FOLDER_NAME" '.[$folder][$version][$name]')

APR_UTIL_FOLDER_NAME=apr-util
APR_UTIL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$APR_UTIL_FOLDER_NAME" '.[$folder][$version][$name]')

PCRE_FOLDER_NAME=pcre2
PCRE_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$PCRE_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/httpd.conf ]; then
	printf "httpd.conf not found\n"
	exit
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/httpd-vhosts.conf ]; then
	printf "httpd-vhosts.conf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/apachectl" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$APR_FOLDER_NAME/$APR_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$APR_UTIL_FOLDER_NAME/$APR_UTIL_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$PCRE_FOLDER_NAME/$PCRE_VERSION/install.sh $((DEPTH+1))

	cd $HOME/sources/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="httpd-$VERSION.tar.gz"
	wget -q "https://archive.apache.org/dist/httpd/$ARCHIVE_FILE"
	print_message "${bold}${green}Extracting source code${clear}" $((DEPTH))
	tar -xf $ARCHIVE_FILE
	mv "httpd-"$VERSION $VERSION
	cd $VERSION
	print_message "${bold}${green}Configuring${clear}" $((DEPTH))
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-apr=$HOME/programs/$APR_FOLDER_NAME/$APR_VERSION/bin/apr-1-config --with-apr-util=$HOME/programs/$APR_UTIL_FOLDER_NAME/$APR_UTIL_VERSION/bin/apu-1-config --with-pcre=$HOME/programs/$PCRE_FOLDER_NAME/$PCRE_VERSION/bin/pcre2-config --enable-so --enable-proxy --enable-proxy-fcgi --enable-actions > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/apachectl" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		echo $USER_PASSWORD | sudo -S -p '' chown -R $(whoami) .

		mv conf/httpd.conf ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/httpd.conf.default
		ln -s ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/httpd.conf conf/httpd.conf
		mv conf/extra/httpd-vhosts.conf ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/httpd-vhosts.conf.default
		ln -s ~/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/httpd-vhosts.conf conf/extra/httpd-vhosts.conf
		echo "<html><body><h1>It works! (version: $VERSION)</h1></body></html>" > htdocs/index.html

		touch .envrc
		echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
		echo "" >> .envrc
		direnv allow

		touch start.sh
		echo "apachectl start" >> start.sh

		touch stop.sh
		echo 'apachectl stop' >> stop.sh

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi
fi