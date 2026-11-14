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

LIBGPG_ERROR_FOLDER_NAME=libgpg-error
LIBGPG_ERROR_VERSION=$(jq -r --arg folder "${LIBGPG_ERROR_FOLDER_NAME}" '.[$folder]' latestVersions.json)

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/libgcrypt-config" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 1 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$LIBGPG_ERROR_FOLDER_NAME/$LIBGPG_ERROR_VERSION/install.sh $((DEPTH+1))

	cd "$HOME/sources/$FOLDER_NAME"

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH)) "Y"
	LINK="$(get_protocol_for_binary "https")://$(get_domain_for_binary "www.gnupg.org")/ftp/gcrypt/libgcrypt/libgcrypt-$VERSION.tar.bz2"
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
	
	mv "libgcrypt-$VERSION" $VERSION
	cd $VERSION
	
	print_message "${bold}${green}Configuring${clear}" $((DEPTH)) "Y"
	start_time=$(date +%s)
	./configure --help > $HOME/logs/$FOLDER_NAME/$VERSION/configureHelp.txt 2>&1
	./configure --host=aarch64-apple-darwin --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --disable-dev-random --with-libgpg-error-prefix=$HOME/programs/$LIBGPG_ERROR_FOLDER_NAME/$LIBGPG_ERROR_VERSION --disable-asm > $HOME/logs/$FOLDER_NAME/$VERSION/configureOutput.txt 2>&1
	end_time=$(date +%s)
	elapsed=$(( end_time - start_time ))
	print_message " - ${elapsed}s" 2
	
	sed -i '' 's/fips_mode ()/0 \&\& fips_mode ()/' $HOME/sources/$FOLDER_NAME/$VERSION/random/rndgetentropy.c
	sed -i '' 's/ret = getrandom (buffer, nbytes, GRND_RANDOM);//' $HOME/sources/$FOLDER_NAME/$VERSION/random/rndgetentropy.c
	
	bash $INSTALL_FILES_DIR/makeAndInstall.sh $FOLDER_NAME $VERSION $((DEPTH))

	if [ -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/libgcrypt-config" ]; then
		cd $HOME/programs/$FOLDER_NAME/$VERSION
		SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

		bash $INSTALL_FILES_DIR/clearSourceFolders.sh $FOLDER_NAME $VERSION $ARCHIVE_FILE $((DEPTH))
	fi

	end_time_total=$(date +%s)
	elapsed=$(( end_time_total - start_time_total ))
	print_message "${bold}${yellow}Total${clear} - ${elapsed}s" $((DEPTH))
fi