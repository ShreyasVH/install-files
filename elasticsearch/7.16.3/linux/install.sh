FOLDER_NAME=elasticsearch
VERSION=7.16.3

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"

	cd $HOME/programs/$FOLDER_NAME

	wget "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$VERSION-linux-x86_64.tar.gz"
	tar -xvf "elasticsearch-$VERSION-linux-x86_64.tar.gz"
	mv "elasticsearch-$VERSION" $VERSION
	cd $VERSION

	sudo chown -R $(whoami) .

	touch .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	touch start.sh
	echo "elasticsearch -d" >> start.sh

	touch stop.sh
	rm config/elasticsearch.yml
	ln -s ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/elasticsearch.yml config/elasticsearch.yml
	echo 'PORT=$(grep '\''http.port: '\'' config/elasticsearch.yml | awk '\''{print $2}'\'')' >> stop.sh
	echo 'kill -9 $(lsof -t -i:$PORT)' >> stop.sh

	cd ..
	rm "elasticsearch-$VERSION-linux-x86_64.tar.gz"
fi

cd $HOME/install-files