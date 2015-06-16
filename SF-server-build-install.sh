#!/bin/bash

# check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

cd /home/william-kingsford/
mkdir Downloads
cd Downloads

# install seafile dependencies
apt-get install libevent-dev libcurl4-openssl-dev libglib2.0-dev uuid-dev intltool libsqlite3-dev libmysqlclient-dev libarchive-dev libtool libjansson-dev valac libfuse-dev re2c flex cmake make g++ python-pip
# dependencies that must be compiled from source
wget http://www.tildeslash.com/libzdb/dist/libzdb-2.12.tar.gz
tar xf libzdb-2.12.tar.gz
cd libzdb-2.12
./configure
make
make install
cd ..

#wget https://github.com/ellzey/libevhtp/archive/develop.zip
#unzip develop.zip -d libevhtp
#cd libevhtp/libevhtp-master/

#wget https://github.com/ellzey/libevhtp/archive/1.1.6.tar.gz
#tar xf 1.1.6.tar.gz
#cd libevhtp-1.1.6

git clone https://www.github.com/haiwen/libevhtp.git
cd libevhtp
cmake -DEVHTP_DISABLE_SSL=ON -DEVHTP_BUILD_SHARED=ON
make
make install
# fix bug where onigposix.h isn't properly installed
cp onigurama/onigposix.h /usr/local/include/onigposix.h
cd ..

while true; do
    read -p "Continue? [y/n]" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# install seahub dependencies
pip install python-django sqlite3 python-simplejson PIL chardet gunicorn django-compressor==1.4 django-statisi18n==1.1.2 six python-dateutil
easy_install djblets
apt-get update

cd /home/william-kingsford/SeaFileServer/
mkdir src
cd src
# download and rename source archives
export version=4.1.2
alias wget='wget --content-disposition -nc'
wget https://github.com/haiwen/libsearpc/archive/v3.0-latest.tar.gz
mv v3.0-latest.tar.gz libsearpc-3.0-latest.tar.gz
wget https://github.com/haiwen/ccnet/archive/v${version}-server.tar.gz
mv v${version}-server.tar.gz ccnet-${version}-server.tar.gz
wget https://github.com/haiwen/seafile/archive/v${version}-server.tar.gz
mv v${version}-server.tar.gz seafile-${version}-server.tar.gz
wget https://github.com/haiwen/seahub/archive/v${version}-server.tar.gz
mv v${version}-server.tar.gz seahub-${version}-server.tar.gz

# extract tarballs
tar xf libsearpc-3.0-latest.tar.gz
tar xf ccnet-${version}-server.tar.gz
tar xf seafile-${version}-server.tar.gz
# seahub is python scripts, so is installed differently
cd /home/william-kingsford/SeaFileServer/
tar xf /home/william-kingsford/SeaFileServer/src/seahub-${version}-server.tar.gz
mv seahub-${version}-server seahub

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

# configure seafile
cd seafile-${version}-server/scripts/
echo "REMEMBER TO SET CCNET PORT TO 10003"
./setup-seafile.sh
cd ../../

# deploy server
apt-get install nginx python-flup
service nginx start

iptables -I INPUT 1 -p tcp --dport 8001 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 8082 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 10003 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 12001 -j ACCEPT

wget https://raw.githubusercontent.com/WilliamKingsford/Misc/master/nginx-config
mv nginx-config /etc/nginx/sites-available/site
ln -s /etc/nginx/sites-available/site /etc/nginx/sites-enabled/site
rm /etc/nginx/sites-enabled/default
service nginx restart

echo '"./seafile.sh start" to start seafile'
echo '"./seahub.sh start-fastcgi 8001" to start seahub'
echo "THESE MUST BE RUN AS ROOT"

echo "Remember to work through the guide at http://manual.seafile.com/deploy/deploy_with_nginx.html"

echo "Also make sure that the IP address in the nginx config file is correct and use port 10003 for ccnet"
