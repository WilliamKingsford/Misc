#!/bin/bash

# This script syncs an empty folder with the Seafile server. The purpose of this is to prevent the
# server-side setup time from being counted when tests are run. 

# checks for environment variable for SeaFileLibraries & Logs location, if not defined it's
# assumed the location of these folders is ~
if ! [[ $SEAFILEDIR ]]
then
	SEAFILEDIR=~
fi

# load server info
i=0
while read line; do
        echo $line
        if [[ $i -eq 0 ]]
        then export SEAFILEDIR=$line
        fi
        if [[ $i -eq 1 ]]
        then export SERVERIP=$line
        fi
        if [[ $i -eq 2 ]]
        then export SEAHUBUSER=$line
        fi
        if [[ $i -eq 3 ]]
        then export SEAHUBPASS=$line
        fi
        if [[ $i -eq 4 ]]
        then export SFLIBRARYID=$line
        fi
        i=$((i+1))
done < serverdetails

# this script syncs an empty folder before stopping seaf-cli, to prevent startup time being counted towards sync-time when sync-and-time is run.
echo "sync-empty-folder.sh: Starting seaf-cli and giving it 3 seconds to load"
seaf-cli start > /dev/null 2>&1&
sleep 3

echo "Starting sync..."
seaf-cli sync -l $SFLIBRARYID -s http://$SERVERIP:8001 -d $SEAFILEDIR/SeaFileLibraries/ -u $SEAHUBEMAIL -p $SEAHUBPASS

# run until sync is complete
continue="1"
sleep 5
echo "About to check for sync completion (empty folder)..."
while [ "$continue" -eq "1" ]
do
seaf-cli status > $SEAFILEDIR/Logs/status.txt
sleep 1
if [[ $(awk 'END { print $(NF) }' $SEAFILEDIR/Logs/status.txt) = "synchronized" ]]
then continue="0"
else echo "Checking..."
fi
done

seaf-cli stop

echo "Sync completed with empty folder"
