#Seafile Build Instructions V2

# Must be installed on Ubuntu 12.04

# This assumes gamvrosi/duet (branch: seafile) has already been cloned from GitHub into ~/duet/


# install essential Debian packages

apt-get install libevent-dev libcurl4-openssl-dev libglib2.0-dev uuid-dev intltool \
 libsqlite3-dev libmysqlclient-dev libarchive-dev libtool libjansson-dev valac   \
 libfuse-dev re2c flex python-setuptools cmake git build-essential python-simplejson \
 python-imaging python-pip python-dev unzip
 
# Want postgresql support (instead of sqlite or mysql? If so...
#  sudo apt-get install postgresql postgresql-server-dev-all libpq-dev

# set up easy_install for python2.7  (I'd like to avoid this... but... had to)
#  wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python
#  ... mistake was that I forgot sudo prior to easy_install cmd
 
 
# djblets required python-imaging
# maybe better to build django 1.5.12 rather than use Debian's 1.4.x
# consider adding in postgresql support next time!
 
 
 
 
 #  install libevhtp 
 
cd ~/duet/SeaFileServer
git clone https://www.github.com/haiwen/libevhtp.git
cd libevhtp
cmake -DEVHTP_DISABLE_SSL=OFF -DEVHTP_BUILD_SHARED=ON .
make
sudo make install

# missing header to fix "/usr/local/include/evhtp.h:11:23: fatal error: onigposix.h: No such file or directory"
#  ... this error doesn't show up until much later in the build process, but this is the its origin
sudo cp oniguruma/onigposix.h /usr/local/include/




 #  install libzdb

cd ~/duet/SeaFileServer
git clone https://www.github.com/haiwen/libzdb.git
cd libzdb
chmod +x autogen.sh
./autogen.sh
./configure
make
sudo make install



# update lib
sudo ldconfig



# Download tarballs for thirdpart components

cd /tmp
wget -O Django-1.5.12.tar.gz https://www.djangoproject.com/download/1.5.12/tarball/
wget -O djblets-0.6.14.tar.gz http://downloads.reviewboard.org/releases/Djblets/0.6/Djblets-0.6.14.tar.gz
wget -O gunicorn-0.16.1.tar.gz   http://pypi.python.org/packages/source/g/gunicorn/gunicorn-0.16.1.tar.gz
wget -O flup-1.0.tar.gz  http://pypi.python.org/packages/source/f/flup/flup-1.0.tar.gz
# wget -O chardet-1.0.tar.gz   https://pypi.python.org/packages/source/c/chardet/chardet-1.0.tar.gz
#   unknown if 2.3.0 has any advantages over 1.0
wget -O chardet-2.3.0.tar.gz https://pypi.python.org/packages/source/c/chardet/chardet-2.3.0.tar.gz
wget --no-check-certificate -O python-dateutil-1.5.tar.gz  https://labix.org/download/python-dateutil/python-dateutil-1.5.tar.gz
wget -O six-1.9.0.tar.gz  https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz                                     

# make dir for thirdpart components
mkdir -p ~/duet/SeaFileServer/seahub_thirdpart
cd ~/duet/SeaFileServer/seahub_thirdpart/

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
# easy_install -d . /tmp/chardet-1.0.tar.gz
easy_install -d . /tmp/chardet-2.3.0.tar.gz
easy_install -d . /tmp/python-dateutil-1.5.tar.gz
easy_install -d . /tmp/six-1.9.0.tar.gz

# unzip 2 of the .egg files : otherwise an error was triggered during later build activity
#unzip chardet-1.0-py2.7.egg
#unzip flup-1.0-py2.7.egg
# error doesn't seem to appear any more...

cd ~/duet/SeaFileServer





#  set some paths for building stuff...
export PKG_CONFIG_PATH=$HOME/duet/SeaFileServer/seafile/lib:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=$HOME/duet/SeaFileServer/libsearpc:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=$HOME/duet/SeaFileServer/ccnet:$PKG_CONFIG_PATH



# prep a dir for seafile-sources
mkdir ~/duet/SeaFileServer/seafile-sources

# clone and prepare Seafile source tarballs

# build seafile server
cd ~/duet/SeaFileServer/

git clone https://github.com/haiwen/libsearpc.git
cd libsearpc
git reset --hard v3.0-latest
./autogen.sh
./configure
make dist
cp *.tar.gz ~/duet/SeaFileServer/seafile-sources/
cd ..

git clone https://github.com/haiwen/ccnet.git
cd ccnet
git reset --hard v4.1.1-server
./autogen.sh
./configure CFLAGS="-pg -g -O2" LDFLAGS="-pg"
make dist
cp *.tar.gz ~/duet/SeaFileServer/seafile-sources/
cd ..

git clone https://github.com/haiwen/seafile.git
cd seafile
git reset --hard v4.1.1-server
./autogen.sh
./configure CFLAGS="-pg -g -O2" LDFLAGS="-pg"
make dist
cp *.tar.gz ~/duet/SeaFileServer/seafile-sources/
cd ..

git clone https://github.com/haiwen/seahub.git
cd seahub
git reset --hard v4.1.1-server
sudo pip install -r requirements.txt    # did this to get around what looked like missing dependencies 
                                        #  (debs _were_ installed, but not seemingly recognized)
                                        # Pillow and Django were installed...
./tools/gen-tarball.py --version=4.1.1 --branch=HEAD
cp *.tar.gz ~/duet/SeaFileServer/seafile-sources/
cd ..

git clone https://github.com/haiwen/seafobj.git
cd seafobj
git reset --hard v4.1.1-server
make dist
cp *.tar.gz ~/duet/SeaFileServer/seafile-sources/
cd ..

git clone https://github.com/haiwen/seafdav.git
cd seafdav
git reset --hard v4.1.1-server
make
cp *.tar.gz ~/duet/SeaFileServer/seafile-sources/
cd ..

# Now, the seafile build system/script requires that a few of the sources are "tagged" with the same version number...
# ...so we go to ~/duet/SeaFileServer/seafile-sources, untar some of them, change the dir names to have the same version number & retar

cd ~/duet/SeaFileServer/seafile-sources/

tar xzvf seafile-4.1.4.tar.gz
mv seafile-4.1.4 seafile-4.1.1
tar czvf seafile-4.1.1.tar.gz seafile-4.1.1

#tar xzvf seahub-<version>.tar.gz
#mv seahub-<version> seahub-4.1.1
#tar czvf seahub-4.1.1.tar.gz seahub-4.1.1

#  Build the server+components and stuff in tarball 

cd ~/duet/SeaFileServer

$HOME/duet/SeaFileServer/seafile/scripts/build/build-server.py --libsearpc_version=1.2.2 --ccnet_version=1.4.2 --seafile_version=4.1.1  --thirdpartdir=$HOME/duet/SeaFileServer/seahub_thirdpart --srcdir=$HOME/duet/SeaFileServer/seafile-sources --outputdir=$HOME/duet/SeaFileServer/seafile-server-pkgs --version=4.1.2 --builddir=/mnt/ --keep --nostrip

echo "Build complete. Seafile server tarball can be found in $HOME/duet/SeaFileServer/seafile-server-pkgs"
