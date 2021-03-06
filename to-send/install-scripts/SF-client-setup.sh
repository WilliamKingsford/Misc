#!/bin/bash

# set seafile library/log root directory
echo "If you want to set up our Seafile folders (SeaFileLibraries and Logs folders) in a custom location,"
echo "enter it here. Leave it blank to set up in ~/"
read SEAFILEDIR

if [[ -z "$SEAFILEDIR" ]]
then #echo "SEAFILEDIR=$HOME" >> ~/.bashrc
echo "$HOME" >> TestScripts/serverdetails
SEAFILEDIR=$HOME
else #echo "SEAFILEDIR=${SEAFILEDIR%/}" >> ~/.bashrc # remove trailing slash (if present)
echo "${SEAFILEDIR%/}" >> TestScripts/serverdetails
SEAFILEDIR=${SEAFILEDIR%/}
fi

# make directories
mkdir $SEAFILEDIR/SeaFileLibraries $SEAFILEDIR/Logs $SEAFILEDIR/Logs/StoredLogs
# put data-processing scripts into StoredLogs folder
cp TestScripts/data-processing/*.sh $SEAFILEDIR/Logs/StoredLogs/

# get seafile server info to configure SF-server-remote-restart.sh
echo "Enter Ubuntu username on Seafile Server machine:"
read SERVERUSER;
echo "Enter Ubuntu password on Seafile Server machine (must not contain '|'):"
read SERVERPASS;
echo "Enter ssh name of Seafile Server (e.g. c157):"
read SERVERNAME;

# get directory this script is located in so we can find TestScripts directory
SFCLIENTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# generate SF-server-remote-restart.exp from template and replace placeholders with actual server info
cp $SFCLIENTDIR/TestScripts/SF-server-remote-restart-template.exp $SFCLIENTDIR/TestScripts/SF-server-remote-restart.exp
sed -i "s|SERVERUSER|$SERVERUSER|g" $SFCLIENTDIR/TestScripts/SF-server-remote-restart.exp
sed -i "s|SERVERNAME|$SERVERNAME|g" $SFCLIENTDIR/TestScripts/SF-server-remote-restart.exp
sed -i "s|SERVERPASS|$SERVERPASS|g" $SFCLIENTDIR/TestScripts/SF-server-remote-restart.exp

# permanently set max_user_watches so inotify watch limit shouldn't be an issue
sudo sh -c 'echo "fs.inotify.max_user_watches=30000" >> /etc/sysctl.conf'

# GET LIBRARY ID, IP, USERNAME, PASSWORD FROM SERVER, PERMANENTLY EXPORT ENV VARIABLE FOR THESE
echo "Enter the IP address you set for Seafile on the server machine:"
read SERVERIP
#echo "SERVERIP=$SERVERIP" >> ~/.bashrc
echo "$SERVERIP" >> TestScripts/serverdetails
echo "Enter the email you set for Seahub on the server machine:"
read SEAHUBEMAIL
#echo "SEAHUBEMAIL=$SEAHUBEMAIL" >> ~/.bashrc
echo "$SEAHUBEMAIL" >> TestScripts/serverdetails
echo "Enter the password you set for Seahub on the server machine:"
read SEAHUBPASS
#echo "SEAHUBPASS=$SEAHUBPASS" >> ~/.bashrc
echo "$SEAHUBPASS" >> TestScripts/serverdetails
echo "Enter the Library ID of the library you want to sync:"
read SFLIBRARYID
#echo "SFLIBRARYID=$SFLIBRARYID" >> ~/.bashrc
echo "$SFLIBRARYID" >> TestScripts/serverdetails

# copy TestScripts over
cp -r TestScripts $SEAFILEDIR/

echo "Seafile client now configured."
