#!/bin/bash

echo "This script assumes that SF-client-build-install.sh has already been run."
echo ""
echo "This is a script to recompile & install ccnet and seafile."
echo "This script is intended to be run from the SeaFileClient directory in the duet GitHub directory."
read -r -p "${1:-Continue? [y/N]} " response
case $response in
    [yY][eE][sS]|[yY]) 
        ;;
    *)
        echo "Aborted"
        exit
        ;;
esac

echo "Recompiling/installing ccnet and seafile..."

# Remove old ccnet and seafile executables
sudo rm /usr/bin/seaf-daemon /usr/bin/ccnet

export version=4.1.2
export PREFIX=/usr
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="$PREFIX/bin:$PATH"

cd ccnet-${version}
./configure --prefix=$PREFIX
make clean
make
sudo make install
cd ..

cd seafile-${version}/
./configure --prefix=$PREFIX --disable-gui
make clean
make
sudo make install
cd ..
