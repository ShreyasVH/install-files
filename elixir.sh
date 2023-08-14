FOLDER_NAME=elixir
VERSION=1.15.4

FOLDER_NAME_ERLANG=erlang
ERLANG_VERSION=25.3.2.5

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
make
sudo make install PREFIX=$HOME/programs/$FOLDER_NAME/$VERSION