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

bash $INSTALL_FILES_DIR/createRequiredFolders.sh $FOLDER_NAME $VERSION 0 1

cd $HOME/programs/$FOLDER_NAME

git clone git@github.com:langfuse/langfuse.git
mv langfuse $VERSION
cd $VERSION
cd web
touch .envrc
NODE_VERSION=20.4.0
echo "export PATH=\$HOME/programs/node/$NODE_VERSION/bin:\$PATH" >> .envrc
# echo 

direnv allow
source .envrc

npm install turbo@^1.13.4 --global
corepack enable
corepack prepare pnpm@9.5.0 --activate
turbo prune --scope=web --docker

cp ../out/pnpm-lock.yaml ./pnpm-lock.yaml
cp ../out/pnpm-workspace.yaml ./pnpm-workspace.yaml
cp -rp ../out/json/* .

pnpm install --frozen-lockfile
cp -rp ../out/full/* .

NODE_OPTIONS='--max-old-space-size=8192' turbo run build --filter=web...

npm install -g --no-package-lock --no-save prisma@6.3.0


DATABASE_USERNAME=shreyas
DATABASE_PASSWORD=password
DATABASE_HOST=127.0.0.1
DATABASE_PORT=1369
DATABASE_NAME=langfuse

export DATABASE_URL="postgresql://${}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}"

bash entrypoint.sh