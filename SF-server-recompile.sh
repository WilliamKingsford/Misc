#!/bin/bash

# check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# build seafile server
cd /home/william-kingsford/SeaFileServer/src/

cd libsearpc-3.0-latest
./autogen.sh
./configure
make
make install
cd ..

cd ccnet-${version}-server
./autogen.sh
./configure --disable-client --enable-server   # `export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig` if libsearpc is not found
make
make install
cd ..

cd seafile-${version}-server
./autogen.sh
./configure --disable-client --enable-server
make
make install
cd ..

# refresh system libraries cache
ldconfig

service nginx restart

echo '"./seafile.sh start" to start seafile'
echo '"./seahub.sh start 8001" to start seahub'
echo "THESE MUST BE RUN AS ROOT"
