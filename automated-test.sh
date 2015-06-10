#!/bin/bash

# This script automatically tests a number of different file number/size combinations

# tests that the script is run from the correct location
if [ "$(pwd)" != "/home/william-kingsford" ]
then
	echo "You must run this script from /home/william-kingsford"
	exit
fi

# test a range of 4kB files
for i in `seq 1000 1000 10000`;
do
	echo "Testing $i x 4kB files"
	python maketree.py $((i+1)) 1 0 $((i+1)) 0 4000 SeaFileLibraries/
	./Misc/sync-and-time.sh
	mv Logs/iostat.txt Logs/StoredLogs/$ix4000B.txt
	rm Logs/iostat_pid.txt
	echo "$i x 4kB: $finish nanoseconds" >> Logs/all-times.txt
done


