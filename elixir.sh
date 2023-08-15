FOLDER_NAME=elixir
VERSION=1.15.4

FOLDER_NAME_ERLANG=erlang
ERLANG_VERSION=26.0.2

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

make clean

export PATH=$HOME/programs/$FOLDER_NAME_ERLANG/$ERLANG_VERSION/bin:$PATH

git clone https://github.com/elixir-lang/elixir.git
cd elixir
git checkout "v"$VERSION
make
sudo make install PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION

cd $HOME/programs/$FOLDER_NAME/$VERSION
sudo chown -R $(whoami) .

touch .envrc
echo 'export PATH=$HOME/programs/'"$FOLDER_NAME_ERLANG/$ERLANG_VERSION/bin:"'$PATH' >> .envrc
echo "" >> .envrc
echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
echo "" >> .envrc
direnv allow

cd $HOME/sources/$FOLDER_NAME
rm -rf elixir