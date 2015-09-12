#!/bin/bash

# This script performs a sync and separates logs into parts (pre-sync, sync, post-sync cleanup)
# and stores them in a timestamped folder.

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

# test for valid arguments
if [[ $# -eq 0 ]]
then echo "Syntax:"
echo "generating no files: sync-and-time-log.sh 0"
echo "generating files:    sync-and-time-log.sh 1 <# of files> <size of files (B)>"
exit
fi
if ! ( [[ $# -eq 1 ]] || [[ $# -eq 3 ]] )
then echo "Invalid number of arguments."
echo "Syntax:"
echo "generating no files: sync-and-time-log.sh 0"
echo "generating files:    sync-and-time-log.sh 1 <# of files> <size of files (B)>"
exit
fi
if [[ $# -eq 1 ]] && ! [[ $1 -eq 0 ]]
then echo "Invalid arguments. If only one argument is given it must be 0 (generate no files)."
exit
fi
if ( [[ $# -eq 3 ]] && [[ ! $1 -eq 1 ]] ) || ( [[ $1 -eq 1 ]] && ! [[ $# -eq 3 ]] )
then echo "If the first argument is 1 then there must be 3 total arguments (1, number of files, size of files) and vice versa."
exit
fi

echo "EMPTY FOLDER PRE-SYNC: Starting seaf-cli and giving it 3 seconds to load"
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

echo "Sync completed with empty folder, adding marker to log file"
mv ~/.ccnet/logs/seafile.log ~/.ccnet/logs/seafile-empty-sync.log

# generate files for sync if first argument is 1
if [[ $1 -eq 1 ]]
then echo "Generating files" 
python $SEAFILEDIR/TestScripts/maketree.py $(($2+1)) 1 0 $(($2+1)) 0 $3 $SEAFILEDIR/SeaFileLibraries/
else echo "Test with no added files"
fi

# clear cache on client
sync
sh -c 'echo 3 > /proc/sys/vm/drop_caches'

echo "FILE SYNC: Starting seaf-cli"
seaf-cli start > /dev/null 2>&1&

start=$(date +%s%N)
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

seaf-cli stop

echo "Sync completed with files, adding marker to log file"
mv ~/.ccnet/logs/seafile.log ~/.ccnet/logs/seafile-file-sync.log

seaf-cli start > /dev/null 2>&1&
echo "Restart: Starting seaf-cli and giving it 3 seconds to load."
sleep 3

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

echo "Sync completed with deleted files, adding marker to log file"
mv ~/.ccnet/logs/seafile.log ~/.ccnet/logs/seafile-deleted-sync.log
# moving log files to timestamped folder
timestamp=$(date +'%Y-%m-%d-%R')
mkdir ~/.ccnet/logs/${timestamp}
mv ~/.ccnet/logs/seafile-*-sync.log ~/.ccnet/logs/${timestamp} 

# print time taken
echo "time taken (in nanoseconds):" $finish

# process log files
rm $SEAFILEDIR/Logs/top-iotop_pid.txt $SEAFILEDIR/Logs/free_pid.txt $SEAFILEDIR/Logs/status.txt
if [[ $1 -eq 0 ]]
then mv $SEAFILEDIR/Logs/free.txt $SEAFILEDIR/Logs/free-nofiles.txt
mv $SEAFILEDIR/Logs/top.txt $SEAFILEDIR/Logs/top-nofiles.txt
mv $SEAFILEDIR/Logs/iotop.txt $SEAFILEDIR/Logs/iotop-nofiles.txt
else mv $SEAFILEDIR/Logs/free.txt $SEAFILEDIR/Logs/free-${2}x${3}B.txt
mv $SEAFILEDIR/Logs/top.txt $SEAFILEDIR/Logs/top-${2}x${3}B.txt
mv $SEAFILEDIR/Logs/iotop.txt $SEAFILEDIR/Logs/iotop-${2}x${3}B.txt
fi

# free memory on c157 by running seaf-gc.sh over ssh and clear cache on client
$SEAFILEDIR/TestScripts/SF-server-remote-restart.exp
sync
sh -c 'echo 3 > /proc/sys/vm/drop_caches'
