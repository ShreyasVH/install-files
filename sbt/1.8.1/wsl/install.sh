FOLDER_NAME=sbt
VERSION=1.8.1

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"

	cd $HOME/programs/$FOLDER_NAME

	wget "https://github.com/sbt/sbt/releases/download/v$VERSION/sbt-$VERSION.tgz"
	tar -xvf "sbt-$VERSION.tgz"
	ls
	mv sbt $VERSION

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd ..
	rm "sbt-$VERSION.tgz"
fi
