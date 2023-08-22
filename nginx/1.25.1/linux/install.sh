FOLDER_NAME=nginx
VERSION=1.25.1

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

	wget "http://nginx.org/download/nginx-"$VERSION".tar.gz"
	tar -xvf "nginx-"$VERSION".tar.gz"
	mv "nginx-"$VERSION $VERSION
	cd $VERSION
	./configure --prefix=$HOME/programs/nginx/$VERSION
	make
	sudo make install

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	rm conf/nginx.conf
	ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/wsl/nginx.conf conf/nginx.conf

	touch start.sh
	echo "nginx" >> start.sh

	touch stop.sh
	echo 'nginx -s stop' >> stop.sh

	cd $HOME/sources/$FOLDER_NAME
	rm -rf $VERSION
	rm "nginx-"$VERSION".tar.gz"
fi