VERSION=1.25.1

if [ ! -d "$HOME/sources" ]; then
	mkdir "$HOME/sources"
fi

if [ ! -d "$HOME/programs" ]; then
	mkdir "$HOME/programs"
fi

if [ ! -d "$HOME/sources/nginx" ]; then
	mkdir "$HOME/sources/nginx"
fi

if [ ! -d "$HOME/programs/nginx" ]; then
	mkdir "$HOME/programs/nginx"
fi

if [ ! -d "$HOME/programs/nginx/$VERSION" ]; then
	mkdir "$HOME/programs/nginx/$VERSION"
fi

cd $HOME/sources/nginx

make clean distclean

wget "http://nginx.org/download/nginx-"$VERSION".tar.gz"
tar -xvf "nginx-"$VERSION".tar.gz"
mv "nginx-"$VERSION $VERSION
cd $VERSION
./configure --prefix=$HOME/programs/nginx/$VERSION
make
sudo make install