version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)
MAJOR_VERSION=$(echo $VERSION | cut -d '.' -f 1)
MINOR_VERSION=$(echo $VERSION | cut -d '.' -f 2)
VERSION_STRING=$MAJOR_VERSION"."$MINOR_VERSION

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

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/memflush" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	cd "$HOME/sources/$FOLDER_NAME"

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	LINK="$(get_protocol_for_binary "https")://$(get_domain_for_binary "launchpad.net")/libmemcached/$VERSION_STRING/$VERSION/+download/libmemcached-$VERSION.tar.gz"
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
	
	mv "libmemcached-$VERSION" $VERSION
	cd $VERSION
	
	print_message "${bold}${green}Configuring${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	sed '/ac_cv_have_htonll/ {
  :start
  N
  /fi$/!b start
  s/if ac_fn_cxx_try_compile "$LINENO"; then :.*fi/ac_cv_have_htonll=no/
}' $HOME/sources/$FOLDER_NAME/$VERSION/configure > $HOME/sources/$FOLDER_NAME/$VERSION/configureCopy
	rm $HOME/sources/$FOLDER_NAME/$VERSION/configure
	mv $HOME/sources/$FOLDER_NAME/$VERSION/configureCopy $HOME/sources/$FOLDER_NAME/$VERSION/configure
	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chmod 755 $HOME/sources/$FOLDER_NAME/$VERSION/configure
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2

	sed -i 's/opt_servers == false/opt_servers == NULL/' $HOME/sources/$FOLDER_NAME/$VERSION/clients/memflush.cc
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/memflush" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi