VERSION=3.6.3
FOLDER_NAME=maven
MAJOR_VERSION=3

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"

	cd $HOME/programs/$FOLDER_NAME

	wget "https://archive.apache.org/dist/maven/maven-$MAJOR_VERSION/$VERSION/binaries/apache-maven-$VERSION-bin.tar.gz"
	tar -xvf "apache-maven-$VERSION-bin.tar.gz"
	mv "apache-maven-"$VERSION $VERSION

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd ..
	rm "apache-maven-$VERSION-bin.tar.gz"
fi
