#!/bin/bash

# This script generates a set of files, syncs them with Seafile server, then tests how long
# it takes for Seafile to place inotify watches and confirm that the files have not been
# changed. 

# read our seafile libraries/logs directory
read SEAFILEDIR < serverdetails
cd $SEAFILEDIR

echo "This script will automatically delete the previous Logs/all-times.txt and any logs still in Logs/StoredLogs/."
echo "If you don't want this, cancel the script in the next 10 seconds."
sleep 10

# delete old data files
echo "Deleting previous data: $SEAFILEDIR/Logs/all-times.txt"
rm $SEAFILEDIR/Logs/all-times.txt
rm $SEAFILEDIR/Logs/StoredLogs/*.txt

# pre-emptively clear caches on both machines
echo "Clearing caches on both server and client"
$SEAFILEDIR/TestScripts/SF-server-remote-restart.exp
sync
sh -c 'echo 3 > /proc/sys/vm/drop_caches'

# test a range of 4kB files
for i in `seq 0 1000 10000`;
do
	echo "Testing ${i} x 4kB files"
	echo "${i} x 4kB completion time in nanoseconds" >> $SEAFILEDIR/Logs/all-times.txt
	python $SEAFILEDIR/TestScripts/maketree.py $((i+1)) 1 0 $((i+1)) 0 4000 $SEAFILEDIR/SeaFileLibraries/
	# not actually empty, just using this script because this part does not need to be timed
	$SEAFILEDIR/TestScripts/sync-empty-folder.sh
	# time how long it takes seafile to place inotify watches to confirm files have not changed
	start=$(date +%s%N)
	seaf-cli start
	# run until sync is complete
	continue="1"
	echo "About to check for sync completion (previously synced folder)..."
	while [ "$continue" -eq "1" ]
	do
		seaf-cli status > $SEAFILEDIR/Logs/status.txt
		sleep 0.1
		if [[ $(awk 'END { print $(NF) }' $SEAFILEDIR/Logs/status.txt) = "synchronized" ]]
		then continue="0"
		else echo "Checking..."
		fi
	done
	finish=$(($(date +%s%N)-$start))
	
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
	
	# free memory on c157 by running seaf-gc.sh over ssh
	$SEAFILEDIR/TestScripts/SF-server-remote-restart.exp
done
echo "" >> $SEAFILEDIR/Logs/all-times.txt # newline
