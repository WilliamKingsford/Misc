#!/bin/bash

# This script syncs a folder that has had sync-empty-folder.sh already run on it, but has since had files
# added while seaf-daemon was not active. It times the sync and records performance data from top, iotop 
# and free and writes this data to log files.

# check if running as root (needed for iotop)
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# checks for environment variable for SeaFileLibraries & Logs location, if not defined it's
# assumed the location of these folders is ~
if ! [[ $SEAFILEDIR ]]
then
	SEAFILEDIR=~
fi
cd $SEAFILEDIR

echo "sync-and-time.sh: Starting seaf-cli"
start=$(date +%s%N)
seaf-cli start > /dev/null 2>&1&

# start tracking detailed cpu/io data every 0.1 second, running in background
# nohup is necessary to run a process in the background through ssh without hangups
nohup $SEAFILEDIR/TestScripts/top-iotop-repeat.sh > /dev/null 2>&1&
echo $! > $SEAFILEDIR/Logs/top-iotop_pid.txt
nohup $SEAFILEDIR/TestScripts/free-repeat.sh > $SEAFILEDIR/Logs/free.txt 2>&1&
echo $! > $SEAFILEDIR/Logs/free_pid.txt

# upload files
echo "Starting sync..."

# run until sync is complete
continue="1"
echo "About to check for sync completion (adding files)..."
while [[ "$continue" -eq "1" ]]
do
seaf-cli status > $SEAFILEDIR/Logs/status.txt
# write sync status to file to find when sync begins
sleep 0.1
if [[ $(awk 'END { print $(NF) }' $SEAFILEDIR/Logs/status.txt) = "synchronized" ]]
then continue="0"
else echo "Checking..."
fi
done

echo "Sync completed"

finish=$(($(date +%s%N)-$start))
# end operf, top-iotop and free processes
kill -15 `cat $SEAFILEDIR/Logs/top-iotop_pid.txt`
kill -15 `cat $SEAFILEDIR/Logs/free_pid.txt`

# empty and desync library for future tests
echo "Emptying library"
rm -rf $SEAFILEDIR/SeaFileLibraries/*

# run until sync is complete
continue="1"
sleep 5
echo "About to check for sync completion (removing files)..."
while [[ "$continue" -eq "1" ]]
do
seaf-cli status > $SEAFILEDIR/Logs/status.txt
sleep 1
if [ $(awk 'END { print $(NF) }' $SEAFILEDIR/Logs/status.txt) = "synchronized" ]
then continue="0"
else echo "Checking..."
fi
done

echo "Desyncing library"
seaf-cli desync -d $SEAFILEDIR/SeaFileLibraries/
seaf-cli stop

# print time taken
echo "time taken (in nanoseconds):" $finish
# write time taken to log file
echo "$finish" >> $SEAFILEDIR/Logs/all-times.txt
