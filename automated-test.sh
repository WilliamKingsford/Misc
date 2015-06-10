#!/bin/bash

# This script automatically tests a number of different file number/size combinations

# tests that the script is run from the correct location
if [ "$(pwd)" != "/home/william-kingsford" ]
then
	echo "You must run this script from /home/william-kingsford"
	exit
fi

# test a range of 4kB files
#for i in `seq 1000 1000 10000`;
for i in `seq 1000 1000 3000`;
do
	echo "Testing ${i} x 4kB files"
	python maketree.py $((i+1)) 1 0 $((i+1)) 0 4000 SeaFileLibraries/
	./Misc/sync-and-time.sh
	mv Logs/iostat.txt Logs/StoredLogs/$ix4000B.txt
	rm Logs/iostat_pid.txt
	echo "${i} x 4kB: ${finish} nanoseconds" >> Logs/all-times.txt
done
echo "" >> Logs/all-times.txt # newline

# test 10000 x 10B files to see if seafile syncs partial blocks
echo "Testing 10000 x 10B files"
python maketree.py 10001 1 0 10001 0 10 SeaFileLibraries/
./Misc/sync-and-time.sh
mv Logs/iostat.txt Logs/StoredLogs/10000x10B.txt
rm Logs/iostat_pid.txt
echo "10000 x 10B: ${finish} nanoseconds" >> Logs/all-times.txt
echo "" >> Logs/all-times.txt # newline

# test a range of sizes for 1000 files
#for i in `seq 0 1 10`;
for i in `seq 0 1 2`;
do
	j=$((2**i))
	echo "Testing 1000 x $((j * 4))kB files"
	python maketree.py 1001 1 0 1001 0 $((j * 4000)) SeaFileLibraries/
	./Misc/sync-and-time.sh
	mv Logs/iostat.txt Logs/StoredLogs/1000x$((j * 4000))B.txt
	rm Logs/iostat_pid.txt
	echo "1000 x $((j * 4))kB: ${finish} nanoseconds" >> Logs/all-times.txt
done
