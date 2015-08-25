#!/bin/bash

sudo apt-get update
sudo apt-get install autoconf automake libtool libevent-dev libcurl4-openssl-dev libgtk2.0-dev uuid-dev intltool libsqlite3-dev valac libjansson-dev libqt4-dev cmake libfuse-dev make expect

cd ~/duet/SeaFileClient

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
./configure CFLAGS="-pg -g -O2" LDFLAGS="-Wl,--no-as-needed -ldl -pg" --prefix=$PREFIX
make clean
make
sudo make install
cd ..

cd seafile-${version}/
./autogen.sh
./configure CFLAGS="-pg -g -O2" LDFLAGS="-pg" --prefix=$PREFIX --disable-gui
make clean
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
