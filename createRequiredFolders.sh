FOLDER_NAME=$1
VERSION=$2
SOURCES_REQUIRED=$3
LOGS_REQUIRED=$4

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ "1" == "$SOURCES_REQUIRED" ]; then
	if [ ! -d "$HOME/sources" ]; then
		mkdir "$HOME/sources"
	fi

	if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
		mkdir "$HOME/sources/$FOLDER_NAME"
	fi

	if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
		mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"
	fi
fi

if [ "1" == "$LOGS_REQUIRED" ]; then
	if [ ! -d "$HOME/logs" ]; then
		mkdir "$HOME/logs"
	fi

	if [ ! -d "$HOME/logs/$FOLDER_NAME" ]; then
		mkdir "$HOME/logs/$FOLDER_NAME"
	fi

	if [ ! -d "$HOME/logs/$FOLDER_NAME/$VERSION" ]; then
		mkdir "$HOME/logs/$FOLDER_NAME/$VERSION"
	fi
fi