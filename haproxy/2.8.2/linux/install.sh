FOLDER_NAME=haproxy
VERSION=2.8.2
MINOR_VERSION=2.8

OPENSSL_FOLDER_NAME=openssl
OPENSSL_VERSION=3.0.10

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

	cd $HOME/sources/$FOLDER_NAME

	make clean distclean

	wget "https://www.haproxy.org/download/$MINOR_VERSION/src/haproxy-$VERSION.tar.gz"
	tar -xvf "haproxy-$VERSION.tar.gz"
	mv "haproxy-$VERSION" $VERSION
	cd $VERSION
	make PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION TARGET=linux USE_OPENSSL=1 SSL_INC=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/include SSL_LIB=$HOME/programs/$OPENSSL_FOLDER_NAME/$OPENSSL_VERSION/lib
	sudo make install PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/sbin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	touch start.sh
	echo "sudo haproxy -f ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/haproxy.cfg -D" >> start.sh

	touch stop.sh
	echo 'sudo kill -9 $(sudo lsof -t -i:80)' >> stop.sh

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "haproxy-$VERSION.tar.gz"
fi
