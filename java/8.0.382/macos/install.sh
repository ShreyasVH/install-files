FOLDER_NAME=java
VERSION=8.0.382

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	cd $HOME/programs/$FOLDER_NAME

	wget -q "https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u382-b05/openlogic-openjdk-8u382-b05-mac-x64.zip"
	unzip "openlogic-openjdk-8u382-b05-mac-x64.zip"
	mv "openlogic-openjdk-8u382-b05-mac-x64/jdk1.8.0_382.jdk" $VERSION

	cd $HOME/programs/$FOLDER_NAME/$VERSION
	sudo chown -R $(whoami) .

	cd $HOME/programs/$FOLDER_NAME
	rm "openlogic-openjdk-8u382-b05-mac-x64.zip"
fi
