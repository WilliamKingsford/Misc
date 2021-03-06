# Seafile Server Recompile & Install Script, assuming SF-server-build-install.sh has already been run
# Derived from a script written by davygravy on http://forum.doozan.com/read.php?2,21772,21772

# check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#  set some paths for building stuff...
export PKG_CONFIG_PATH=$HOME/duet/SeaFileServer/seafile/lib:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=$HOME/duet/SeaFileServer/libsearpc:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=$HOME/duet/SeaFileServer/ccnet:$PKG_CONFIG_PATH

# move old seafile-sources
timestamp=$(date +'%Y-%m-%d-%R')
mkdir ~/duet/SeaFileServer/seafile-sources/
mkdir ~/duet/SeaFileServer/seafile-sources/${timestamp}
mv ~/duet/SeaFileServer/seafile-sources/*.tar.gz ~/duet/SeaFileServer/seafile-sources/${timestamp}/

# prepare new Seafile source tarballs

cd ~/duet/SeaFileServer/

cd libsearpc
./autogen.sh
./configure
make dist
cp *.tar.gz ~/duet/SeaFileServer/seafile-sources/
cd ..

cd ccnet
./autogen.sh
./configure CFLAGS="-pg -g -O2" LDFLAGS="-pg"
make dist
cp *.tar.gz ~/duet/SeaFileServer/seafile-sources/
cd ..

cd seafile
./autogen.sh
./configure CFLAGS="-pg -g -O2" LDFLAGS="-pg"
make dist
cp *.tar.gz ~/duet/SeaFileServer/seafile-sources/
cd ..

cd seahub
sudo pip install -r requirements.txt    # did this to get around what looked like missing dependencies 
                                        #  (debs _were_ installed, but not seemingly recognized)
                                        # Pillow and Django were installed...
./tools/gen-tarball.py --version=4.1.1 --branch=HEAD
cp *.tar.gz ~/duet/SeaFileServer/seafile-sources/
cd ..

cd seafobj
make dist
cp *.tar.gz ~/duet/SeaFileServer/seafile-sources/
cd ..

cd seafdav
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

# remove old seafile-server tars
rm ~/duet/SeaFileServer/seafile-server-pkgs/seafile-server_4.1.2_x86-64.tar.gz
rm /mnt/seafile-server-build/ -rf

mkdir ~/duet/SeaFileServer/seafile-server-pkgs

$HOME/duet/SeaFileServer/seafile/scripts/build/build-server.py --libsearpc_version=1.2.2 --ccnet_version=1.4.2 --seafile_version=4.1.1  --thirdpartdir=$HOME/duet/SeaFileServer/seahub_thirdpart --srcdir=$HOME/duet/SeaFileServer/seafile-sources --outputdir=$HOME/duet/SeaFileServer/seafile-server-pkgs --version=4.1.2 --builddir=/mnt/ --keep --nostrip

# remove .dbg from name for simplicity
mv ~/duet/SeaFileServer/seafile-server-pkgs/seafile-server_4.1.2_x86-64.dbg.tar.gz ~/duet/SeaFileServer/seafile-server-pkgs/seafile-server_4.1.2_x86-64.tar.gz

# ===BEGIN INSTALLATION===

apt-get update

# make directory to extract files to (so we don't overwrite any config files accidentally)
mkdir ~/SeaFileServer-clean-install/
cd ~/SeaFileServer-clean-install/
cp ~/duet/SeaFileServer/seafile-server-pkgs/seafile-server_4.1.2_x86-64.tar.gz seafile-server_4.1.2_x86-64-custom.tar.gz
tar -xvf seafile-server_4.1.2_x86-64-custom.tar.gz
# move tar to installed directory with timestamp added
timestamp=$(date +'%Y-%m-%d-%R')
mv seafile-server_4.1.2_x86-64-custom.tar.gz ~/SeaFileServer/installed/seafile-server_4.1.2_x86-64-custom-${timestamp}.tar.gz
mv ~/SeaFileServer/seafile-server-4.1.2 ~/SeaFileServer/seafile-server-4.1.2-${timestamp}
mv seafile-server-4.1.2 ~/SeaFileServer/
cd ~/
rmdir SeaFileServer-clean-install 

cd ~/SeaFileServer/seafile-server-4.1.2
./setup-seafile.sh
echo "AN ERROR OF \"Failed to sync seahub database.\" IS NORMAL AND CAN BE IGNORED."

# give garbage collection script execute permissions
chmod +x seaf-gc.sh

service nginx start

echo '"~/SeaFileServer/seafile-server-4.1.2/seafile.sh start" to start seafile'
echo '"~/SeaFileServer/seafile-server-4.1.2/seahub.sh start 8001" to start seahub'
echo "THESE MUST BE RUN AS ROOT"

echo "Remember to work through the guide at http://manual.seafile.com/deploy/deploy_with_nginx.html"

echo "Also make sure that the IP address in the nginx config file is correct"
