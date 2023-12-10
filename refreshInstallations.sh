date

programs=()
versions=()
failed_versions=()


programs+=("java")
versions+=("8.0.382 11.0.19 17.0.7 19 19.0.2 20.0.2 21 21.0.1")


programs+=("python")
versions+=("3.11.4")

programs+=("php")
versions+=("8.2.7 8.2.8 8.2.9 8.2.10 8.2.11")

programs+=("ruby")
versions+=("3.2.2")

programs+=("go")
versions+=("1.21.4")

programs+=("scala")
versions+=("3.2.2 3.3.1")

programs+=("kotlin")
versions+=("1.9.20")

programs+=("perl")
versions+=("5.38.0")

programs+=("redis")
versions+=("7.0.12 7.0.13 7.2.1 7.2.3")

programs+=("memcached")
versions+=("1.6.21 1.6.22")



programs+=("rmq")
versions+=("3.12.2")



programs+=("apache")
versions+=("2.4.55 2.4.56 2.4.57 2.4.58")


programs+=("nginx")
versions+=("1.25.1 1.25.3")



programs+=("mysql")
versions+=("8.0.34 8.1.0")

programs+=("mongo")
versions+=("6.0.6 7.0.1 7.0.3 7.1.1")

programs+=("postgres")
versions+=("15.3 15.4 16.0 16.1")

programs+=("neo4j")
versions+=("5.11.0 5.13.0")


programs+=("elasticsearch")
versions+=("7.16.3 7.17.15 8.9.2 8.10.0 8.10.1 8.10.2 8.10.3 8.10.4 8.11.0 8.11.1")

programs+=("kibana")
versions+=("8.9.2 8.11.1")


programs+=("haproxy")
versions+=("2.8.2 2.8.3")


programs+=("maven")
versions+=("3.8.8 3.9.5")

programs+=("sbt")
versions+=("1.7.2 1.8.1 1.9.7")


programs+=("dotnet-core")
versions+=("7.0.402 8.0.100")

programs+=("rsyslog")
versions+=("8.2308.0")

programs+=("node")
versions+=("16.3.0 18.16.0 19.9.0")


rm -rf ~/sources_new
mv ~/sources ~/sources_bkp
mkdir ~/sources

rm -rf ~/logs_new
mv ~/logs ~/logs_bkp
mkdir ~/logs

rm -rf ~/programs_new
mv ~/programs ~/programs_bkp
mkdir ~/programs

JQ_VERSION=1.7

mkdir ~/programs/jq
cp -rp ~/programs_bkp/jq/$JQ_VERSION ~/programs/jq

direnv allow

WGET_WERSION=1.21.4
PKG_CONFIG_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "wget" --arg version "$WGET_WERSION" --arg name "pkg-config" '.[$folder][$version][$name]')
OPENSSL_VERSION=$(cat "$VERSION_MAP_PATH" | jq -r --arg folder "wget" --arg version "$WGET_WERSION" --arg name "openssl" '.[$folder][$version][$name]')

mkdir ~/programs/pkg-config
cp -rp ~/programs_bkp/pkg-config/$PKG_CONFIG_VERSION ~/programs/pkg-config

mkdir ~/programs/openssl
cp -rp ~/programs_bkp/openssl/$OPENSSL_VERSION ~/programs/openssl

mkdir ~/programs/wget
cp -rp ~/programs_bkp/wget/$WGET_WERSION ~/programs/wget

# bash jq/1.7/macos/install.sh
# bash wget/1.21.4/macos/install.sh

direnv allow

for ((i = 0; i < ${#programs[@]}; i++)); do
    program="${programs[i]}"
    versions_list="${versions[i]}"
    echo "Program: $program"

    path_to_check=$(cat "programData.json" | jq -r --arg folder $program '.[$folder].path')
    
    # Split versions into an array
    IFS=" " read -ra version_array <<< "$versions_list"
    
    for version in "${version_array[@]}"; do
        echo -e "\tVersion: $version"
        bash $program/$version/macos/install.sh
        cd $INSTALL_FILES_DIR
        if [ ! -e "$HOME/programs/$program/$version"$path_to_check ]; then
            failed_versions+=("$program-$version")
        fi
    done
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
