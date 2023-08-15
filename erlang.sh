FOLDER_NAME=erlang
VERSION=26.0.2

PERL_VERSION=5.38.0
FOLDER_NAME_PERL=perl

FOLDER_NAME_OPENSSL=openssl
OPENSSL_VERSION=3.0.10

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/$FOLDER_NAME" ]; then
	mkdir "$HOME/sources/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME"
fi

if [ ! -d "$HOME/programs/$FOLDER_NAME/$VERSION" ]; then
	mkdir "$HOME/programs/$FOLDER_NAME/$VERSION"
fi

cd $HOME/sources/$FOLDER_NAME

make clean distclean

export PATH=$HOME/programs/$FOLDER_NAME_PERL/$PERL_VERSION/bin:$PATH

wget "https://github.com/erlang/otp/releases/download/OTP-$VERSION/otp_src_$VERSION.tar.gz"
tar -xvf "otp_src_$VERSION.tar.gz"
mv "otp_src_$VERSION" $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/$FOLDER_NAME/$VERSION --with-ssl=$HOME/programs/$FOLDER_NAME_OPENSSL/$OPENSSL_VERSION
make
sudo make install

cd $HOME/programs/$FOLDER_NAME/$VERSION
sudo chown -R $(whoami) .

touch .envrc
echo 'export PATH=$HOME/programs/'"$FOLDER_NAME/$VERSION/bin:"'$PATH' >> .envrc
echo "" >> .envrc
direnv allow

cd $HOME/sources/$FOLDER_NAME
rm -rf $VERSION
rm "otp_src_$VERSION.tar.gz"