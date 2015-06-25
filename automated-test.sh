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
	echo "Testing ${i} x 4kB files"
	echo "${i} x 4kB completion time in nanoseconds" >> /home/william-kingsford/Logs/all-times.txt
	/home/william-kingsford/Misc/sync-empty-folder.sh
	python maketree.py $((i+1)) 1 0 $((i+1)) 0 4000 /home/william-kingsford/SeaFileLibraries/
	/home/william-kingsford/Misc/sync-and-time.sh
	grep seaf /home/william-kingsford/Logs/top-raw.txt > /home/william-kingsford/Logs/top.txt
	grep seaf /home/william-kingsford/Logs/iotop-raw.txt > /home/william-kingsford/Logs/iotop.txt
	rm /home/william-kingsford/Logs/top-raw.txt /home/william-kingsford/Logs/iotop-raw.txt
	mv /home/william-kingsford/Logs/top.txt /home/william-kingsford/Logs/StoredLogs/${i}x4000B-top.txt
	rm /home/william-kingsford/Logs/top_pid.txt
	mv /home/william-kingsford/Logs/iotop.txt /home/william-kingsford/Logs/StoredLogs/${i}x4000B-iotop.txt
	rm /home/william-kingsford/Logs/iotop_pid.txt
	mv /home/william-kingsford/Logs/free.txt /home/william-kingsford/Logs/StoredLogs/${i}x4000B-free.txt
	rm /home/william-kingsford/Logs/free_pid.txt
	# free memory on c157 by running seaf-gc.sh over ssh
	/home/william-kingsford/Misc/c157.exp
done
echo "" >> /home/william-kingsford/Logs/all-times.txt # newline

# test 10000 x 10B files to see if seafile syncs partial blocks
echo "Testing 10000 x 10B files"
echo "10000 x 10B completion time in nanoseconds" >> /home/william-kingsford/Logs/all-times.txt
/home/william-kingsford/Misc/sync-empty-folder.sh
python maketree.py 10001 1 0 10001 0 10 /home/william-kingsford/SeaFileLibraries/
/home/william-kingsford/Misc/sync-and-time.sh
grep seaf /home/william-kingsford/Logs/top-raw.txt > /home/william-kingsford/Logs/top.txt
grep seaf /home/william-kingsford/Logs/iotop-raw.txt > /home/william-kingsford/Logs/iotop.txt
rm /home/william-kingsford/Logs/top-raw.txt /home/william-kingsford/Logs/iotop-raw.txt
mv /home/william-kingsford/Logs/top.txt Logs/StoredLogs/10000x10B-top.txt
rm /home/william-kingsford/Logs/top_pid.txt
mv /home/william-kingsford/Logs/iotop.txt Logs/StoredLogs/10000x10B-iotop.txt
rm /home/william-kingsford/Logs/iotop_pid.txt
mv /home/william-kingsford/Logs/free.txt Logs/StoredLogs/10000x10B-free.txt
rm /home/william-kingsford/Logs/free_pid.txt
# free memory on c157 by running seaf-gc.sh over ssh
/home/william-kingsford/Misc/c157.exp
echo "" >> /home/william-kingsford/Logs/all-times.txt # newline

# test a range of sizes for 1000 files
for i in `seq 1 1 10`;
do
	j=$((2**i))
	echo "Testing 1000 x $((j * 4))kB files"
	echo "1000 x $((j * 4))kB completion time in nanoseconds" >> /home/william-kingsford/Logs/all-times.txt
	/home/william-kingsford/Misc/sync-empty-folder.sh
	python maketree.py 1001 1 0 1001 0 $((j * 4000)) /home/william-kingsford/SeaFileLibraries/
	/home/william-kingsford/Misc/sync-and-time.sh
	grep seaf /home/william-kingsford/Logs/top-raw.txt > /home/william-kingsford/Logs/top.txt
	grep seaf /home/william-kingsford/Logs/iotop-raw.txt > /home/william-kingsford/Logs/iotop.txt
	rm /home/william-kingsford/Logs/top-raw.txt /home/william-kingsford/Logs/iotop-raw.txt
	mv /home/william-kingsford/Logs/top.txt Logs/StoredLogs/1000x$((j * 4000))B-top.txt
	rm /home/william-kingsford/Logs/top_pid.txt
	mv /home/william-kingsford/Logs/iotop.txt Logs/StoredLogs/1000x$((j * 4000))B-iotop.txt
	rm /home/william-kingsford/Logs/iotop_pid.txt
	mv /home/william-kingsford/Logs/free.txt Logs/StoredLogs/1000x$((j * 4000))B-free.txt
	rm /home/william-kingsford/Logs/free_pid.txt
	# free memory on c157 by running seaf-gc.sh over ssh
	/home/william-kingsford/Misc/c157.exp
done
