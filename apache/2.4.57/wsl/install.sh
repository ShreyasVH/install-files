FOLDER_NAME=apache
VERSION=2.4.57

APR_FOLDER_NAME=apr
APR_VERSION=1.7.4

APR_UTIL_FOLDER_NAME=apr-util
APR_UTIL_VERSION=1.6.3

PCRE_FOLDER_NAME=pcre2
PCRE_VERSION=10.42

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
	mkdir "$HOME/sources/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"

	bash $INSTALL_FILES_DIR/$APR_FOLDER_NAME/$APR_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$APR_UTIL_FOLDER_NAME/$APR_UTIL_VERSION/wsl/install.sh
	bash $INSTALL_FILES_DIR/$PCRE_FOLDER_NAME/$PCRE_VERSION/wsl/install.sh

	cd $HOME/sources/$FOLDER_NAME

	wget "https://dlcdn.apache.org/httpd/httpd-"$VERSION".tar.gz"
	tar -xvf "httpd-"$VERSION".tar.gz"
	mv "httpd-"$VERSION $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-apr=$HOME/programs/$APR_FOLDER_NAME/$APR_VERSION/bin/apr-1-config --with-apr-util=$HOME/programs/$APR_UTIL_FOLDER_NAME/$APR_UTIL_VERSION/bin/apu-1-config --with-pcre=$HOME/programs/$PCRE_FOLDER_NAME/$PCRE_VERSION/bin/pcre2-config
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	rm conf/httpd.conf
	ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/httpd.conf conf/httpd.conf
	rm conf/extra/httpd-vhosts.conf
	ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/httpd-vhosts.conf conf/extra/httpd-vhosts.conf

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	touch start.sh
	echo "apachectl start" >> start.sh

	touch stop.sh
	echo 'apachectl stop' >> stop.sh

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "httpd-"$VERSION".tar.gz"
fi

