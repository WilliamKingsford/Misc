#!/bin/bash

# Seafile Server Build & Install script
# Derived from a script written by davygravy on http://forum.doozan.com/read.php?2,21772,21772

# check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "THIS SEAFILE INSTALL ONLY WORKS ON UBUNTU 12.04"
echo ""
echo "This is a script to install prerequisites, build a Seafile Server tarball and install it to ~/SeaFileServer."
echo "You must set up nginx server after this. See http://manual.seafile.com/deploy/deploy_with_nginx.html"
echo "This script is intended to be run from the SeaFileServer directory in the seafile branch of the duet GitHub directory."
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

DIR=$(pwd)

# install essential Debian packages
apt-get install libevent-dev libcurl4-openssl-dev libglib2.0-dev uuid-dev intltool \
 libsqlite3-dev libmysqlclient-dev libarchive-dev libtool libjansson-dev valac   \
 libfuse-dev re2c flex python-setuptools cmake git build-essential python-simplejson \
 python-imaging python-pip python-dev unzip
 
# install libevhtp
cd $DIR
cd libevhtp
cmake -DEVHTP_DISABLE_SSL=OFF -DEVHTP_BUILD_SHARED=ON .
make
make install

# missing header to fix "/usr/local/include/evhtp.h:11:23: fatal error: onigposix.h: No such file or directory"
#  ... this error doesn't show up until much later in the build process, but this is the its origin
cp oniguruma/onigposix.h /usr/local/include/

# install libzdb
cd $DIR
cd libzdb
chmod +x autogen.sh
./autogen.sh
./configure
make
make install

# update lib
ldconfig

# Download tarballs for third-party components
cd /tmp
wget -O Django-1.5.12.tar.gz https://www.djangoproject.com/download/1.5.12/tarball/
wget -O djblets-0.6.14.tar.gz http://downloads.reviewboard.org/releases/Djblets/0.6/Djblets-0.6.14.tar.gz
wget -O gunicorn-0.16.1.tar.gz   http://pypi.python.org/packages/source/g/gunicorn/gunicorn-0.16.1.tar.gz
wget -O flup-1.0.tar.gz  http://pypi.python.org/packages/source/f/flup/flup-1.0.tar.gz
wget -O chardet-2.3.0.tar.gz https://pypi.python.org/packages/source/c/chardet/chardet-2.3.0.tar.gz
wget --no-check-certificate -O python-dateutil-1.5.tar.gz  https://labix.org/download/python-dateutil/python-dateutil-1.5.tar.gz
wget -O six-1.9.0.tar.gz  https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz                                     

# make dir for thirdpart components
mkdir -p $DIR/seahub_thirdpart
cd $DIR/seahub_thirdpart/

# I ran into a problem where I didn't have adequate space for the django to be built in tmp...
#
#  "error: Setup script exited with error: No space left on device"
#
#  had to resort to fixing /usr/lib/python2.6/dist-packages/setuptools/command/easy_install.py
#  see http://stackoverflow.com/questions/7621103/easy-install-downloading-directory
#  FIX = /usr/lib/python2.6/dist-packages/setuptools/command/easy_install.py
#  find "tempfile.mkdtemp", change to something like below ... (/mnt is where I mounted sda3 ... lots of space)
#              tmpdir = tempfile.mkdtemp(prefix="easy_install-",dir="/mnt")
chmod 777 -R /mnt  # make writeable, so that python has lots of build space

export PYTHONPATH=.
easy_install -d . /tmp/Django-1.5.12.tar.gz
easy_install -d . /tmp/djblets-0.6.14.tar.gz
easy_install -d . /tmp/gunicorn-0.16.1.tar.gz
easy_install -d . /tmp/flup-1.0.tar.gz
easy_install -d . /tmp/chardet-2.3.0.tar.gz
easy_install -d . /tmp/python-dateutil-1.5.tar.gz
easy_install -d . /tmp/six-1.9.0.tar.gz

cd $DIR

#  set some paths for building stuff...
export PKG_CONFIG_PATH=$DIR/seafile/lib:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=$DIR/libsearpc:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=$DIR/ccnet:$PKG_CONFIG_PATH

# prep a dir for seafile-sources
mkdir $DIR/seafile-sources

# prepare Seafile source tarballs

cd $DIR

cd libsearpc
./autogen.sh
./configure
make dist
cp *.tar.gz $DIR/seafile-sources/
cd ..

cd ccnet
./autogen.sh
./configure
make dist
cp *.tar.gz $DIR/seafile-sources/
cd ..

cd seafile
./autogen.sh
./configure
make dist
cp *.tar.gz $DIR/seafile-sources/
cd ..

cd seahub
sudo pip install -r requirements.txt    # did this to get around what looked like missing dependencies 
                                        #  (debs _were_ installed, but not seemingly recognized)
                                        # Pillow and Django were installed...
./tools/gen-tarball.py --version=4.1.1 --branch=HEAD
cp *.tar.gz $DIR/seafile-sources/
rm seahub-4.1.1.tar.gz
cd ..

cd seafobj
make dist
cp *.tar.gz $DIR/seafile-sources/
cd ..

cd seafdav
make
cp *.tar.gz $DIR/seafile-sources/
cd ..

# Now, the seafile build system/script requires that a few of the sources are "tagged" with the same version number...
# ...so we go to $DIR/seafile-sources, untar some of them, change the dir names to have the same version number & retar

cd $DIR/seafile-sources/

tar xzvf seafile-4.1.4.tar.gz
mv seafile-4.1.4 seafile-4.1.1
tar czvf seafile-4.1.1.tar.gz seafile-4.1.1
rm seafile-4.1.1 -rf

#  Build the server+components and stuff in tarball 

cd $DIR

mkdir $DIR/seafile-server-pkgs

$DIR/seafile/scripts/build/build-server.py --libsearpc_version=1.2.2 --ccnet_version=1.4.2 --seafile_version=4.1.1  --thirdpartdir=$DIR/seahub_thirdpart --srcdir=$DIR/seafile-sources --outputdir=$DIR/seafile-server-pkgs --version=4.1.2 --builddir=/mnt/ --keep --nostrip

# remove .dbg from name for simplicity
mv $DIR/seafile-server-pkgs/seafile-server_4.1.2_x86-64.dbg.tar.gz $DIR/seafile-server-pkgs/seafile-server_4.1.2_x86-64.tar.gz

# ===BEGIN INSTALLATION===

apt-get update

mkdir ~/SeaFileServer ~/SeaFileServer/TestScripts
cd ~/SeaFileServer

# copy test scripts over
cp $DIR/TestScripts/* ~/SeaFileServer/TestScripts/*

cp $DIR/seafile-server-pkgs/seafile-server_4.1.2_x86-64.tar.gz seafile-server_4.1.2_x86-64.tar.gz
tar -xvf seafile-server_4.1.2_x86-64.tar.gz
mkdir installed
mv seafile-server_4.1.2_x86-64.tar.gz installed

apt-get update
apt-get install python2.7 python-setuptools python-imaging sqlite3

cd seafile-server-4.1.2
echo "Your IP address is "`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`" (needed for next part)"
echo "Other than IP address, use defaults for everything and choose any name you want."
read -rsp $'Press any key to continue...\n' -n1 key
./setup-seafile.sh
cd ..

# increase max open files
sudo sh -c 'echo "* soft nofile 65535" >> /etc/security/limits.conf'
sudo sh -c 'echo "* hard nofile 65535" >> /etc/security/limits.conf'

# give garbage collection script execute permissions
chmod +x seaf-gc.sh

# set up nginx
cd $DIR
./SF-server-nginx-setup.sh

# ===== PRINT LIBRARY ID =====
# ===== PRINT LIBRARY ID =====
# ===== PRINT LIBRARY ID =====

echo '"~/SeaFileServer/seafile-server-4.1.2/seafile.sh start" to start seafile'
echo '"~/SeaFileServer/seafile-server-4.1.2/seahub.sh start 8001" to start seahub'
echo "THESE MUST BE RUN AS ROOT"
