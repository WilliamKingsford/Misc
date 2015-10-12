#!/bin/bash

echo "THIS SEAFILE INSTALL ONLY WORKS ON UBUNTU 12.04"
echo ""
echo "This is a script to build and install everything needed for the seafile client side."
echo "This script is intended to be run from the SeaFileClient directory in the seafile branch of the duet GitHub directory."
read -r -p "${1:-Continue? [y/N]} " response
case $response in
    [yY][eE][sS]|[yY]) 
        ;;
    *)
        echo "Aborted"
        exit
        ;;
esac

echo "Installing..."

sudo apt-get update
sudo apt-get install autoconf automake libtool libevent-dev libcurl4-openssl-dev libgtk2.0-dev \
	uuid-dev intltool libsqlite3-dev valac libjansson-dev libqt4-dev cmake libfuse-dev make expect iotop

export version=4.1.2
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
make clean
make
sudo make install
cd ..

cd seafile-${version}/
./autogen.sh
./configure --prefix=$PREFIX --disable-gui
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
cd seafile-cli
mkdir ~/.seafile-client
./seaf-cli init -d ~/.seafile-client  # initialise seafile client with this folder

# set user ownership on .ccnet directory so logs can be viewed
chmod -R $SUDO_USER ~/.ccnet/