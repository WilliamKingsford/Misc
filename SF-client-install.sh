#!/bin/bash

sudo apt-get update
sudo apt-get install autoconf automake libtool libevent-dev libcurl4-openssl-dev libgtk2.0-dev uuid-dev intltool libsqlite3-dev valac libjansson-dev libqt4-dev cmake libfuse-dev make

# download and rename source archives
export version=4.1.2
alias wget='wget --content-disposition -nc'
wget https://github.com/haiwen/libsearpc/archive/v3.0-latest.tar.gz
mv v3.0-latest.tar.gz libsearpc-3.0-latest.tar.gz
wget https://github.com/haiwen/ccnet/archive/v${version}.tar.gz
mv v${version}.tar.gz ccnet-${version}.tar.gz
wget https://github.com/haiwen/seafile/archive/v${version}.tar.gz
mv v${version}.tar.gz seafile-${version}.tar.gz
wget https://github.com/haiwen/seafile-client/archive/v${version}.tar.gz
mv v${version}.tar.gz seafile-client-${version}.tar.gz

tar xf libsearpc-3.0-latest.tar.gz
tar xf ccnet-${version}.tar.gz
tar xf seafile-${version}.tar.gz
tar xf seafile-client-${version}.tar.gz

export PREFIX=/usr
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="$PREFIX/bin:$PATH"

cd libsearpc-3.0-latest
./autogen.sh
./configure --prefix=$PREFIX
make
sudo make install
cd ..

cd ccnet-${version}
./autogen.sh
./configure --prefix=$PREFIX
make
sudo make install
cd ..

cd seafile-${version}/
./autogen.sh
./configure --prefix=$PREFIX --disable-gui
make
sudo make install
cd ..

# install cmake to /opt/cmake
wget http://www.cmake.org/files/v3.2/cmake-3.2.3-Linux-x86_64.sh
chmod +x cmake-3.2.3-Linux-x86_64.sh
./cmake-3.2.3-Linux-x86_64.sh

cd seafile-client-${version}
../cmake-3.2.3-Linux-x86_64/bin/cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX .
make
sudo make install
cd ..

# install seafile command line interface
mkdir seafile-cli
cd seafile-cli
wget https://raw.githubusercontent.com/haiwen/seafile/master/app/seaf-cli
mkdir ~/.seafile-client
chmod +x seaf-cli
./seaf-cli init -d ~/.seafile-client  # initialise seafile client with this folder
./seaf-cli start

# link seaf-cli so it can be run from anywhere
ln -s `readlink -f seaf-cli` /usr/bin/
