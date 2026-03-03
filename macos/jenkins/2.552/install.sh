version_dir=$(dirname "$(realpath "$0")")

VERSION=$(basename $version_dir)

program_dir=$(dirname "$version_dir")
FOLDER_NAME=$(basename $program_dir)

os_dir=$(dirname $program_dir)
OS=$(basename $os_dir)

DEPTH=1
if [ $# -ge 1 ]; then
    DEPTH=$1
fi

source $INSTALL_FILES_DIR/utils.sh

cd $INSTALL_FILES_DIR

JAVA_FOLDER_NAME=java
JAVA_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$JAVA_FOLDER_NAME" '.[$folder][$version][$name]')

MAVEN_FOLDER_NAME=maven
MAVEN_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "$FOLDER_NAME" --arg version "$VERSION" --arg name "$MAVEN_FOLDER_NAME" '.[$folder][$version][$name]')

if [ ! -e $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/jenkins.conf ]; then
	printf "jenkins.conf not found\n"
	exit
fi

if [ ! -e "$HOME/programs/$FOLDER_NAME/$VERSION/bin/jenkins.war" ]; then
	bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

	print_message "${bold}${yellow}Installing ${FOLDER_NAME} ${VERSION}${clear}" $((DEPTH))

	bash $INSTALL_FILES_DIR/$OS/$JAVA_FOLDER_NAME/$JAVA_VERSION/install.sh $((DEPTH+1))
	bash $INSTALL_FILES_DIR/$OS/$MAVEN_FOLDER_NAME/$MAVEN_VERSION/install.sh $((DEPTH+1))

	CREATE_USER_FILE_PATH=$(realpath macos/$FOLDER_NAME/$VERSION/createUser.groovy)
	CREATE_CREDENTIALS_FILE_PATH=$(realpath macos/$FOLDER_NAME/$VERSION/createCredentials.groovy)
	FETCH_UPDATE_CENTER_DATA_PATH=$(realpath macos/$FOLDER_NAME/$VERSION/fetchUpdateCenterData.groovy)
	CREATE_MULTI_BRANCH_PIPELINE_PATH=$(realpath macos/$FOLDER_NAME/$VERSION/createMultibranchPipeline.groovy)

	cd $HOME/programs/$FOLDER_NAME

	print_message "${bold}${green}Downloading source code${clear}" $((DEPTH))
	ARCHIVE_FILE="jenkins.war"
	wget --show-progress "https://github.com/jenkinsci/jenkins/releases/download/jenkins-$VERSION/$ARCHIVE_FILE" > $HOME/logs/$FOLDER_NAME/$VERSION/download.txt 2>&1
	mkdir $VERSION
	mv $ARCHIVE_FILE $VERSION
	cd $VERSION

	mkdir jenkins_home

	SUDO_ASKPASS=$HOME/askpass.sh sudo -A chown -R $(whoami) .

	touch .envrc
	echo "export JAVA_HOME=\$HOME/programs/$JAVA_FOLDER_NAME/$JAVA_VERSION" >> .envrc
	echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> .envrc
	echo "export MAVEN_HOME=\$HOME/programs/$MAVEN_FOLDER_NAME/$MAVEN_VERSION" >> .envrc
	echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> .envrc
	direnv allow

	ln -s $HOME/workspace/myProjects/config-samples/$OS/$FOLDER_NAME/$VERSION/jenkins.conf jenkins.conf

	PORT=$(grep 'port=' jenkins.conf | awk -F= '{print $2}')
	touch start.sh
	echo "PID_FILE=jenkins.pid" >> start.sh
	echo "export JENKINS_HOME=./jenkins_home" >> start.sh
	echo "if [[ ! -e \$PID_FILE ]]; then" >> start.sh
	echo -e "\techo 'Starting'" >> start.sh
	echo -e "\tjava -Djenkins.install.runSetupWizard=false -jar jenkins.war --httpPort=$PORT > server.log 2>&1 &" >> start.sh
	echo -e "\techo \$! > \$PID_FILE" >> start.sh
	echo "fi" >> start.sh

	touch stop.sh
	echo "PID_FILE=jenkins.pid" >> stop.sh
	echo "if [[ -e \$PID_FILE ]]; then" >> stop.sh
	echo -e "\techo 'Stopping'" >> stop.sh
	echo -e "\tkill -9 \$(cat \$PID_FILE)" >> stop.sh
	echo -e "\trm \$PID_FILE" >> stop.sh
	echo "fi" >> stop.sh

	export JAVA_HOME=$HOME/programs/$JAVA_FOLDER_NAME/$JAVA_VERSION
	zsh start.sh

	print_message "${bold}${green}Waiting for jenkins to start${clear}" $((DEPTH))
	JENKINS_URL="http://localhost:$PORT"
	until curl -s -o /dev/null -w "%{http_code}" "$JENKINS_URL/login" | grep -q "200"; do
	  sleep 2
	done

	print_message "${bold}${green}Downloading CLI${clear}" $((DEPTH))
	curl -O -s "${JENKINS_URL}/jnlpJars/jenkins-cli.jar"

	print_message "${bold}${green}Creating user${clear}" $((DEPTH))
	java -jar jenkins-cli.jar -s $JENKINS_URL groovy = < $CREATE_USER_FILE_PATH $JENKINS_USERNAME $JENKINS_PASSWORD

	print_message "${bold}${green}Fetching update center data${clear}" $((DEPTH))
	java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USERNAME:$JENKINS_PASSWORD" groovy = < $FETCH_UPDATE_CENTER_DATA_PATH

	print_message "${bold}${green}Installing default plugins${clear}" $((DEPTH))
	java -jar jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USERNAME:$JENKINS_PASSWORD install-plugin credentials plain-credentials workflow-multibranch workflow-aggregator branch-api github-branch-source cloudbees-folder pipeline-stage-view

	print_message "${bold}${green}Restarting${clear}" $((DEPTH))
	java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USERNAME:$JENKINS_PASSWORD" safe-restart

	print_message "${bold}${green}Waiting for jenkins to start${clear}" $((DEPTH))
	JENKINS_URL="http://localhost:$PORT"
	until curl -s -o /dev/null -w "%{http_code}" "$JENKINS_URL/login" | grep -q "200"; do
	  sleep 2
	done

	print_message "${bold}${green}Setting credentials${clear}" $((DEPTH))
	java -jar jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USERNAME:$JENKINS_PASSWORD groovy = < $CREATE_CREDENTIALS_FILE_PATH $GITHUB_USERNAME $GITHUB_TOKEN_JENKINS

	print_message "${bold}${green}Creating multi branch pipeline${clear}" $((DEPTH))
	java -jar jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USERNAME:$JENKINS_PASSWORD groovy = < $CREATE_MULTI_BRANCH_PIPELINE_PATH "spring-boot-unit-test" $GITHUB_USERNAME "spring-boot-unit-test"

	zsh stop.sh

	print_message "${bold}${green}Clearing${clear}" $((DEPTH))
	cd ..
fi

