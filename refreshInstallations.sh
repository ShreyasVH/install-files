date

programs=()
failed_versions=()


programs+=("java")
programs+=("python")
programs+=("ruby")
programs+=("go")
programs+=("scala")
programs+=("kotlin")
programs+=("perl")
programs+=("redis")
programs+=("memcached")
programs+=("rmq")
programs+=("apache")
programs+=("nginx")
programs+=("mongo")
programs+=("postgres")
programs+=("neo4j")
programs+=("elasticsearch")
programs+=("kibana")
programs+=("haproxy")
programs+=("maven")
programs+=("sbt")
programs+=("dotnet-core")
programs+=("rsyslog")
programs+=("node")
programs+=("erlang")
programs+=("elixir")
programs+=("mongo-cli-tools")
programs+=("phpmyadmin")
programs+=("sqlite3")
programs+=("openssl")
programs+=("php")
programs+=("mysql")

rm -rf ~/sources_new
if [ ! -d ~/sources_bkp ]; then
    mv ~/sources ~/sources_bkp
    mkdir ~/sources
fi

rm -rf ~/logs_new
if [ ! -d ~/logs_bkp ]; then
    mv ~/logs ~/logs_bkp
    mkdir ~/logs
fi

rm -rf ~/programs_new
if [ ! -d ~/programs_bkp ]; then
    mv ~/programs ~/programs_bkp
    mkdir ~/programs
fi


JQ_VERSION=1.7.1

# if [ ! -d "$HOME/programs/jq" ]; then
#     mkdir ~/programs/jq
#     cp -rp ~/programs_bkp/jq/$JQ_VERSION ~/programs/jq
# fi

bash jq/$JQ_VERSION/macos/install.sh

direnv allow

WGET_WERSION=1.24.5
PKG_CONFIG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "wget" --arg version "$WGET_WERSION" --arg name "pkg-config" '.[$folder][$version][$name]')
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "wget" --arg version "$WGET_WERSION" --arg name "openssl" '.[$folder][$version][$name]')

# if [ ! -d "$HOME/programs/pkg-config" ]; then
#     mkdir ~/programs/pkg-config
#     cp -rp ~/programs_bkp/pkg-config/$PKG_CONFIG_VERSION ~/programs/pkg-config
# fi

# if [ ! -d "$HOME/programs/openssl" ]; then
#     mkdir ~/programs/openssl
#     cp -rp ~/programs_bkp/openssl/$OPENSSL_VERSION ~/programs/openssl
# fi

# if [ ! -d "$HOME/programs/wget" ]; then
#     mkdir ~/programs/wget
#     cp -rp ~/programs_bkp/wget/$WGET_WERSION ~/programs/wget
# fi

bash wget/$WGET_WERSION/macos/install.sh

direnv allow

for ((i = 0; i < ${#programs[@]}; i++)); do
    program="${programs[i]}"
    programDirectory=$HOME/install-files/$program
    echo "$program"

    path_to_check=$(cat "programData.json" | jq -r --arg folder $program '.[$folder].path')

    path=$(echo $programDirectory | sed 's/\//\\\//g')
    version=$(cat "latestVersions.json" | jq -r --arg folder $program '.[$folder]')
    printf "\t$version\n"
    bash $programDirectory/$version/macos/install.sh
    cd $INSTALL_FILES_DIR
    if [ ! -e "$HOME/programs/$program/$version"$path_to_check ]; then
        failed_versions+=("$program-$version")
    fi
done

printf "Failed programs:\n"
for element in "${failed_versions[@]}"; do
    printf "${bold}${red}$element${clear}\n"
done


mv ~/programs ~/programs_new
mv ~/programs_bkp ~/programs

mv ~/sources ~/sources_new
mv ~/sources_bkp ~/sources

mv ~/logs ~/logs_new
mv ~/logs_bkp ~/logs

date