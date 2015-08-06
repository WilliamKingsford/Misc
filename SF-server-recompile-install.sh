#Seafile recompile, assuming SF-server-build-install.sh has already been run

# most commands where executed in ~/  (in this case, /home/william-kingsford , homedir of a regular+sudoer user)

# check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#  set some paths for building stuff...
export PKG_CONFIG_PATH=/home/william-kingsford/duet/SeaFileServer/seafile/lib:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/home/william-kingsford/duet/SeaFileServer/libsearpc:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/home/william-kingsford/duet/SeaFileServer/ccnet:$PKG_CONFIG_PATH

# move old seafile-sources
timestamp=$(date +'%Y-%m-%d-%R')
mkdir /home/william-kingsford/duet/SeaFileServer/seafile-sources/
mkdir /home/william-kingsford/duet/SeaFileServer/seafile-sources/${timestamp}
mv /home/william-kingsford/duet/SeaFileServer/seafile-sources/*.tar.gz ~/seafile-sources/${timestamp}/

# prepare new Seafile source tarballs

#cd /home/william-kingsford/SeaFileServer/src/
cd /home/william-kingsford/duet/SeaFileServer/

cd libsearpc
./autogen.sh
./configure
make dist
cp *.tar.gz /home/william-kingsford/duet/SeaFileServer/seafile-sources/
cd ..

cd ccnet
./autogen.sh
./configure CFLAGS="-pg -g -O2" LDFLAGS="-pg"
make dist
cp *.tar.gz /home/william-kingsford/duet/SeaFileServer/seafile-sources/
cd ..

cd seafile
./autogen.sh
./configure CFLAGS="-pg -g -O2" LDFLAGS="-pg"
make dist
cp *.tar.gz /home/william-kingsford/duet/SeaFileServer/seafile-sources/
cd ..

cd seahub
sudo pip install -r requirements.txt    # did this to get around what looked like missing dependencies 
                                        #  (debs _were_ installed, but not seemingly recognized)
                                        # Pillow and Django were installed...
./tools/gen-tarball.py --version=4.1.1 --branch=HEAD
cp *.tar.gz /home/william-kingsford/duet/SeaFileServer/seafile-sources/
cd ..

cd seafobj
make dist
cp *.tar.gz /home/william-kingsford/duet/SeaFileServer/seafile-sources/
cd ..

cd seafdav
make
cp *.tar.gz /home/william-kingsford/duet/SeaFileServer/seafile-sources/
cd ..

# Now, the seafile build system/script requires that a few of the sources are "tagged" with the same version number...
# ...so we go to ~/seafile-sources, untar some of them, change the dir names to have the same version number & retar

cd /home/william-kingsford/duet/SeaFileServer/seafile-sources/

tar xzvf seafile-4.1.4.tar.gz
mv seafile-4.1.4 seafile-4.1.1
tar czvf seafile-4.1.1.tar.gz seafile-4.1.1

#tar xzvf seahub-<version>.tar.gz
#mv seahub-<version> seahub-4.1.1
#tar czvf seahub-4.1.1.tar.gz seahub-4.1.1

#  Build the server+components and stuff in tarball 

cd ~/

# remove old seafile-server tars
rm /home/william-kingsford/duet/SeaFileServer/seafile-server-pkgs/seafile-server_4.1.2_x86-64.tar.gz
rm /mnt/seafile-server-build/ -rf

mkdir /home/william-kingsford/duet/SeaFileServer/seafile-server-pkgs

/home/william-kingsford/duet/SeaFileServer/seafile/scripts/build/build-server.py --libsearpc_version=1.2.2 --ccnet_version=1.4.2 --seafile_version=4.1.1  --thirdpartdir=/home/william-kingsford/duet/SeaFileServer/seahub_thirdpart --srcdir=/home/william-kingsford/duet/SeaFileServer/seafile-sources --outputdir=/home/william-kingsford/duet/SeaFileServer/seafile-server-pkgs --version=4.1.2 --builddir=/mnt/ --keep


# ===BEGIN INSTALLATION===

apt-get update

cd ~/SeaFileServer

cp /home/william-kingsford/duet/SeaFileServer/seafile-server-pkgs/seafile-server_4.1.2_x86-64.tar.gz seafile-server_4.1.2_x86-64-custom.tar.gz
tar -xvf seafile-server_4.1.2_x86-64-custom.tar.gz
mkdir installed
mv seafile-server_4.1.2_x86-64-custom.tar.gz installed

cd seafile-server-4.1.2
./setup-seafile.sh

service nginx start

echo '"./seafile.sh start" to start seafile'
echo '"./seahub.sh start 8001" to start seahub'
echo "THESE MUST BE RUN AS ROOT"

echo "Remember to work through the guide at http://manual.seafile.com/deploy/deploy_with_nginx.html"

echo "Also make sure that the IP address in the nginx config file is correct"
