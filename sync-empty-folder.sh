#!/bin/bash

# this script syncs an empty folder before stopping seaf-cli, to prevent startup time being counted towards sync-time when sync-and-time is run.

# load server info
i=0
while read line; do
        echo $line
        if [[ $i -eq 0 ]]
        then export SERVERIP=$line
        fi
        if [[ $i -eq 1 ]]
        then export SEAHUBUSER=$line
        fi
        if [[ $i -eq 2 ]]
        then export SEAHUBPASS=$line
        fi
        if [[ $i -eq 3 ]]
        then export SFLIBRARYID=$line
        fi
        i=$((i+1))
done < serverdetails

echo "sync-empty-folder.sh: Starting seaf-cli and giving it 3 seconds to load"
seaf-cli start > /dev/null 2>&1&
sleep 3

echo "Starting sync..."
seaf-cli sync -l 4915ec59-c414-47d1-a14e-ed290339172b -s http://142.150.234.157:8001 -d /home/william-kingsford/SeaFileLibraries/ -u will.kingsford@gmail.com -p *hLO8GeH

# run until sync is complete
continue="1"
sleep 5
echo "About to check for sync completion (empty folder)..."
while [ "$continue" -eq "1" ]
do
seaf-cli status > /home/william-kingsford/Logs/status.txt
sleep 1
if [[ $(awk 'END { print $(NF) }' /home/william-kingsford/Logs/status.txt) = "synchronized" ]]
then continue="0"
else echo "Checking..."
fi
done

seaf-cli stop

echo "Sync completed with empty folder"
