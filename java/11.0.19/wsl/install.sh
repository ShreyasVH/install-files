FOLDER_NAME=java
VERSION=11.0.19

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	cd $HOME/programs/$FOLDER_NAME

	wget "https://builds.openlogic.com/downloadJDK/openlogic-openjdk-jre/$VERSION+7/openlogic-openjdk-jre-$VERSION+7-linux-x64.tar.gz"
	tar -xvf "openlogic-openjdk-jre-$VERSION+7-linux-x64.tar.gz"
	mv "openlogic-openjdk-jre-$VERSION+7-linux-x64" $VERSION

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd ..
	rm "openlogic-openjdk-jre-$VERSION+7-linux-x64.tar.gz"
fi

