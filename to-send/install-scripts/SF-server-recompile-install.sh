# Seafile Server Recompile & Install Script, assuming SF-server-build-install.sh has already been run
# Derived from a script written by davygravy on http://forum.doozan.com/read.php?2,21772,21772

# check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "This script assumes that SF-server-build-install.sh has already been run."
echo ""
echo "This is a script to build a Seafile Server tarball and install it to ~/SeaFileServer, moving the old ~/SeaFileServer to ~/SeaFileServer-YYYY-MM-DD-HH-mm."
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

#  set some paths for building stuff...
export PKG_CONFIG_PATH=$DIR/seafile/lib:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=$DIR/libsearpc:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=$DIR/ccnet:$PKG_CONFIG_PATH

# move old seafile-sources
timestamp=$(date +'%Y-%m-%d-%R')
mkdir $DIR/seafile-sources/
mkdir $DIR/seafile-sources/${timestamp}
mv $DIR/seafile-sources/*.tar.gz $DIR/seafile-sources/${timestamp}/

# prepare new Seafile source tarballs

cd $DIR/

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

#tar xzvf seahub-<version>.tar.gz
#mv seahub-<version> seahub-4.1.1
#tar czvf seahub-4.1.1.tar.gz seahub-4.1.1

#  Build the server+components and stuff in tarball 

cd $DIR

# remove old seafile-server tars
rm $DIR/seafile-server-pkgs/seafile-server_4.1.2_x86-64.tar.gz
rm /mnt/seafile-server-build/ -rf

mkdir $DIR/seafile-server-pkgs

$DIR/seafile/scripts/build/build-server.py --libsearpc_version=1.2.2 --ccnet_version=1.4.2 --seafile_version=4.1.1  --thirdpartdir=$DIR/seahub_thirdpart --srcdir=$DIR/seafile-sources --outputdir=$DIR/seafile-server-pkgs --version=4.1.2 --builddir=/mnt/ --keep --nostrip

# remove .dbg from name for simplicity
mv $DIR/seafile-server-pkgs/seafile-server_4.1.2_x86-64.dbg.tar.gz $DIR/seafile-server-pkgs/seafile-server_4.1.2_x86-64.tar.gz

# ===BEGIN INSTALLATION===

apt-get update

# make directory to extract files to (so we don't overwrite any config files accidentally)
mkdir ~/SeaFileServer-clean-install/
cd ~/SeaFileServer-clean-install/
cp $DIR/seafile-server-pkgs/seafile-server_4.1.2_x86-64.tar.gz seafile-server_4.1.2_x86-64-custom.tar.gz
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
echo "This is caused by the install trying to replace the old seahub and failing, but this isn't an issue as we aren't modifying seahub."

# give garbage collection script execute permissions
chmod +x seaf-gc.sh

service nginx start

echo '"~/SeaFileServer/seafile-server-4.1.2/seafile.sh start" to start seafile'
echo '"~/SeaFileServer/seafile-server-4.1.2/seahub.sh start 8001" to start seahub'
echo "THESE MUST BE RUN AS ROOT"

echo "Remember to work through the guide at http://manual.seafile.com/deploy/deploy_with_nginx.html"

echo "Also make sure that the IP address in the nginx config file is correct"
