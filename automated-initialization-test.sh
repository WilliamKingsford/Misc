#!/bin/bash

# This script automatically tests how long it takes seafile to place inotify watches on 
# a set of files that have already been synced

# tests that the script is run from the correct location
if [ "$(pwd)" != "/home/william-kingsford" ]
then
	echo "You must run this script from /home/william-kingsford"
	exit
fi

# test a range of 4kB files
for i in `seq 0 3000 9000`;
do
	echo "Testing ${i} x 4kB files"
	echo "${i} x 4kB completion time in nanoseconds" >> /home/william-kingsford/Logs/all-times.txt
	python maketree.py $((i+1)) 1 0 $((i+1)) 0 4000 /home/william-kingsford/SeaFileLibraries/
	# not actually empty, just using this script because this part does not need to be timed
	/home/william-kingsford/Misc/sync-empty-folder.sh
	# time how long it takes seafile to place inotify watches to confirm files have not changed
	start=$(date +%s%N)
	seaf-cli start
	# run until sync is complete
	continue="1"
	echo "About to check for sync completion (previously synced folder)..."
	while [ "$continue" -eq "1" ]
	do
		seaf-cli status > /home/william-kingsford/Logs/status.txt
		sleep 1
		if [[ $(awk 'END { print $(NF) }' /home/william-kingsford/Logs/status.txt) = "synchronized" ]]
		then continue="0"
		else echo "Checking..."
		fi
	done
	finish=$(($(date +%s%N)-$start))
	
	# empty and desync library for future tests
	echo "Emptying library"
	rm /home/william-kingsford/SeaFileLibraries/*

	# run until sync is complete
	continue="1"
	sleep 5
	echo "About to check for sync completion (removing files)..."
	while [[ "$continue" -eq "1" ]]
	do
	seaf-cli status > /home/william-kingsford/Logs/status.txt
	sleep 1
	if [ $(awk 'END { print $(NF) }' /home/william-kingsford/Logs/status.txt) = "synchronized" ]
	then continue="0"
	else echo "Checking..."
	fi
	done

	echo "Desyncing library"
	seaf-cli desync -d /home/william-kingsford/SeaFileLibraries/
	seaf-cli stop
	
	# print time taken
	echo "time taken (in nanoseconds):" $finish
	# write time taken to log file
	echo "$finish" >> /home/william-kingsford/Logs/all-times.txt
	
	# free memory on c157 by running seaf-gc.sh over ssh
	/home/william-kingsford/Misc/c157.exp
done
echo "" >> /home/william-kingsford/Logs/all-times.txt # newline
