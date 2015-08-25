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

# install seafile command line interface
cd seafile-cli
mkdir ~/.seafile-client
./seaf-cli init -d ~/.seafile-client  # initialise seafile client with this folder

# link seaf-cli so it can be run from anywhere
ln -s `readlink -f seaf-cli` /usr/bin/
