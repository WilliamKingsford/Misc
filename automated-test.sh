#!/bin/bash

# This script automatically tests a number of different file number/size combinations

# tests that the script is run from the correct location
if [ "$(pwd)" != "/home/william-kingsford" ]
then
	echo "You must run this script from /home/william-kingsford"
	exit
fi
# check if running as root (needed for iotop and clearing pagecache)
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "This script will automatically the previous all-times.txt."
echo "If you don't want this, cancel the script in the next 10 seconds."
sleep 10

# delete old data files
echo "Deleting previous data all-times.txt"
rm /home/william-kingsford/Logs/all-times.txt

# pre-emptively clear caches on both machines
echo "Clearing caches on both server and client"
/home/william-kingsford/Misc/c157.exp
sh -c 'echo 1 > /proc/sys/vm/drop_caches'

# test a range of 4kB files
for i in `seq 1000 1000 10000`;
do
	echo "Testing ${i} x 4kB files"
	echo "${i} x 4kB completion time in nanoseconds" >> /home/william-kingsford/Logs/all-times.txt
	/home/william-kingsford/Misc/sync-empty-folder.sh
	python maketree.py $((i+1)) 1 0 $((i+1)) 0 4000 /home/william-kingsford/SeaFileLibraries/
	/home/william-kingsford/Misc/sync-and-time.sh
	mv /home/william-kingsford/Logs/top.txt /home/william-kingsford/Logs/StoredLogs/${i}x4000B-top.txt
	rm /home/william-kingsford/Logs/top_pid.txt
	mv /home/william-kingsford/Logs/iotop.txt /home/william-kingsford/Logs/StoredLogs/${i}x4000B-iotop.txt
	rm /home/william-kingsford/Logs/iotop_pid.txt
	mv /home/william-kingsford/Logs/free.txt /home/william-kingsford/Logs/StoredLogs/${i}x4000B-free.txt
	rm /home/william-kingsford/Logs/free_pid.txt
	# free memory on c157 by running seaf-gc.sh over ssh and clear pagecache on client
	/home/william-kingsford/Misc/c157.exp
	sh -c 'echo 1 > /proc/sys/vm/drop_caches'
done
echo "" >> /home/william-kingsford/Logs/all-times.txt # newline

# test 10000 x 10B files to see if seafile syncs partial blocks
echo "Testing 10000 x 10B files"
echo "10000 x 10B completion time in nanoseconds" >> /home/william-kingsford/Logs/all-times.txt
/home/william-kingsford/Misc/sync-empty-folder.sh
python maketree.py 10001 1 0 10001 0 10 /home/william-kingsford/SeaFileLibraries/
/home/william-kingsford/Misc/sync-and-time.sh
mv /home/william-kingsford/Logs/top.txt Logs/StoredLogs/10000x10B-top.txt
rm /home/william-kingsford/Logs/top_pid.txt
mv /home/william-kingsford/Logs/iotop.txt Logs/StoredLogs/10000x10B-iotop.txt
rm /home/william-kingsford/Logs/iotop_pid.txt
mv /home/william-kingsford/Logs/free.txt Logs/StoredLogs/10000x10B-free.txt
rm /home/william-kingsford/Logs/free_pid.txt
# free memory on c157 by running seaf-gc.sh over ssh and clear pagecache on client
/home/william-kingsford/Misc/c157.exp
sh -c 'echo 1 > /proc/sys/vm/drop_caches'
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
	mv /home/william-kingsford/Logs/top.txt Logs/StoredLogs/1000x$((j * 4000))B-top.txt
	rm /home/william-kingsford/Logs/top_pid.txt
	mv /home/william-kingsford/Logs/iotop.txt Logs/StoredLogs/1000x$((j * 4000))B-iotop.txt
	rm /home/william-kingsford/Logs/iotop_pid.txt
	mv /home/william-kingsford/Logs/free.txt Logs/StoredLogs/1000x$((j * 4000))B-free.txt
	rm /home/william-kingsford/Logs/free_pid.txt
	# free memory on c157 by running seaf-gc.sh over ssh and clear pagecache on client
	/home/william-kingsford/Misc/c157.exp
	sh -c 'echo 1 > /proc/sys/vm/drop_caches'
done
