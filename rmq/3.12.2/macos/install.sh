VERSION=3.12.2
FOLDER_NAME=rmq

ERLANG_VERSION=26.0.2
FOLDER_NAME_ERLANG=erlang

ELIXIR_VERSION=1.15.4
FOLDER_NAME_ELIXIR=elixir

MAKE_VERSION=4.4.1
FOLDER_NAME_MAKE=make

INSTALL_FILES_DIR=$HOME/install-files

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -e $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/rabbitmq.conf ]; then
	printf "rabbitmq.conf not found\n"
	exit
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	bash $INSTALL_FILES_DIR/$FOLDER_NAME_ERLANG/$ERLANG_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$FOLDER_NAME_ELIXIR/$ELIXIR_VERSION/macos/install.sh
	bash $INSTALL_FILES_DIR/$FOLDER_NAME_MAKE/$MAKE_VERSION/macos/install.sh

	cd $HOME/programs/$FOLDER_NAME

	export PATH=$HOME/programs/$FOLDER_NAME_ERLANG/$ERLANG_VERSION/bin:$PATH
	export PATH=$HOME/programs/$FOLDER_NAME_ELIXIR/$ELIXIR_VERSION/bin:$PATH
	export PATH=$HOME/programs/$FOLDER_NAME_MAKE/$MAKE_VERSION/bin:$PATH

	printf "${bold}${yellow}Installing $FOLDER_NAME${clear}\n"

	printf "\t${bold}${green}Downloading source code${clear}\n"
	wget -q --show-progress "https://github.com/rabbitmq/rabbitmq-server/releases/download/v$VERSION/rabbitmq-server-generic-unix-$VERSION.tar.xz"
	printf "\t${bold}${green}Extracting source code${clear}\n"
	tar -xf "rabbitmq-server-generic-unix-$VERSION.tar.xz"
	mv "rabbitmq_server-$VERSION" $VERSION
	cd $VERSION

	echo $USER_PASSWORD | sudo -S -p "" chown -R $(whoami) .

	touch .envrc
	echo 'export RABBITMQ_HOME=$HOME/programs/'"$FOLDER_NAME/$VERSION" >> .envrc
	echo "" >> .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/sbin:"'$PATH' >> .envrc
	echo "" >> .envrc
	echo 'export PATH=$HOME/programs/'"$FOLDER_NAME_ERLANG/$ERLANG_VERSION/bin:"'$PATH' >> .envrc
	echo "" >> .envrc
	direnv allow

	ln -s $HOME/workspace/myProjects/config-samples/$FOLDER_NAME/$VERSION/macos/rabbitmq.conf ./etc/rabbitmq/

	export PATH=$HOME/programs/$FOLDER_NAME/$VERSION/sbin:$PATH

	rabbitmq-plugins enable rabbitmq_management

	touch start.sh
	echo "rabbitmq-server -detached" >> start.sh

	touch stop.sh
	echo "rabbitmqctl stop" >> stop.sh

	cd ..
	rm "rabbitmq-server-generic-unix-$VERSION.tar.xz"
fi

