# Now, the seafile build system/script requires that a few of the sources are "tagged" with the same version number...
# ...so we go to ~/seafile-sources, untar some of them, change the dir names to have the same version number & retar

cd ~/seafile-sources/

tar xzvf seafile-4.1.4.tar.gz
mv seafile-4.1.4 seafile-4.1.1
tar czvf seafile-4.1.1.tar.gz seafile-4.1.1

#tar xzvf seahub-<version>.tar.gz
#mv seahub-<version> seahub-4.1.1
#tar czvf seahub-4.1.1.tar.gz seahub-4.1.1

#  Build the server+components and stuff in tarball 

cd ~/

/home/william-kingsford/seafile/scripts/build/build-server.py --libsearpc_version=1.2.2 --ccnet_version=1.4.2 --seafile_version=4.1.1  --thirdpartdir=/home/william-kingsford/seahub_thirdpart --srcdir=/home/william-kingsford/seafile-sources --outputdir=/home/william-kingsford/seafile-server-pkgs --version=4.1.2 --builddir=/mnt/ --keep

