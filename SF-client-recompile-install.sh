#!/bin/bash

cd ~/duet/SeaFileClient

export PREFIX=/usr
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="$PREFIX/bin:$PATH"

cd ccnet-${version}
./configure CFLAGS="-pg -g -O2" LDFLAGS="-Wl,--no-as-needed -ldl -pg" --prefix=$PREFIX
make clean
make
sudo make install
cd ..

cd seafile-${version}/
./configure CFLAGS="-pg -g -O2" LDFLAGS="-pg" --prefix=$PREFIX --disable-gui
make clean
make
sudo make install
cd ..
