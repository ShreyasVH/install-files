FOLDER_NAME=postgres
VERSION=15.4

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
fi

cd $HOME/sources/$FOLDER_NAME

wget "https://ftp.postgresql.org/pub/source/v$VERSION/postgresql-$VERSION.tar.gz"
tar -xvf "postgresql-$VERSION.tar.gz"
mv "postgresql-"$VERSION $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION
make
sudo make install

cd $HOME/programs/$FOLDER_NAME/$VERSION
sudo chown -R $(whoami) .

export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/bin:$PATH

touch .envrc
echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
echo "" >> .envrc
direnv allow

mkdir data
initdb -d data

cp ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/postgresql.conf data/
cp ~/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/pg_hba.conf data/

pg_ctl start -D data
PORT=$(grep 'port = ' data/postgresql.conf | awk '{print $3}')
createuser -p $PORT -s postgres
createdb -U postgres -p $PORT shreyas
createuser -U postgres -p $PORT -P -s shreyas

touch start.sh
echo "pg_ctl start -D data" >> start.sh

touch stop.sh
echo 'pg_ctl stop -D data' >> stop.sh

bash stop.sh

cd $HOME/sources/$FOLDER_NAME
rm -rf $VERSION
rm "postgresql-$VERSION.tar.gz"