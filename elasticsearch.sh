FOLDER_NAME=elasticsearch
VERSION=8.9.0

JAVA_FOLDER_NAME=java
JAVA_VERSION=17.0.7

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

cd $HOME/programs/$FOLDER_NAME

wget "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$VERSION-darwin-x86_64.tar.gz"
tar -xvf "elasticsearch-$VERSION-darwin-x86_64.tar.gz"
mv "elasticsearch-$VERSION" $VERSION
cd $VERSION

sudo chown -R $(whoami) .

touch .envrc
echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
echo "" >> .envrc
echo 'export PATH=$HOME/programs/'"$JAVA_FOLDER_NAME/$JAVA_VERSION/Contents/Home/bin:"'$PATH' >> .envrc
echo "" >> .envrc
direnv allow

touch start.sh
echo "elasticsearch -d" >> start.sh

touch stop.sh
cp ~/workspace/myProjects/config-samples/elasticsearch/$VERSION/elasticsearch.yml config/
echo 'PORT=$(grep '\''http.port: '\'' config/elasticsearch.yml | awk '\''{print $2}'\'')' >> stop.sh
echo 'kill -9 $(lsof -t -i:$PORT)' >> stop.sh

cd ..
rm "elasticsearch-$VERSION-darwin-x86_64.tar.gz"