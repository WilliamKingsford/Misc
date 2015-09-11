#!/bin/bash

# This script generates a number of sets of files and produces logs for time taken and performance
# metrics for each combination of files.

# check if running as root (needed for iotop and clearing pagecache)
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

echo "This script will automatically delete the previous all-times.txt."
echo "If you don't want this, cancel the script in the next 10 seconds."
sleep 10

# delete old data files
echo "Deleting previous data: $SEAFILEDIR/Logs/all-times.txt"
rm $SEAFILEDIR/Logs/all-times.txt

# pre-emptively clear caches on both machines
echo "Clearing caches on both server and client"
$SEAFILEDIR/TestScripts/SF-server-remote-restart.exp
sync
sh -c 'echo 3 > /proc/sys/vm/drop_caches'

# test a range of 4kB files
for i in `seq 1000 1000 10000`;
do
	echo "Testing ${i} x 4kB files"
	echo "${i} x 4kB completion time in nanoseconds" >> $SEAFILEDIR/Logs/all-times.txt
	$SEAFILEDIR/TestScripts/sync-empty-folder.sh
	python $SEAFILEDIR/TestScripts/maketree.py $((i+1)) 1 0 $((i+1)) 0 4000 $SEAFILEDIR/SeaFileLibraries/
	# clear page cache to ensure new files are not still in memory
	sync
	sh -c 'echo 3 > /proc/sys/vm/drop_caches'
	$SEAFILEDIR/TestScripts/sync-and-time.sh
	mv $SEAFILEDIR/Logs/top.txt $SEAFILEDIR/Logs/StoredLogs/${i}x4000B-top.txt
	mv $SEAFILEDIR/Logs/iotop.txt $SEAFILEDIR/Logs/StoredLogs/${i}x4000B-iotop.txt
	mv $SEAFILEDIR/Logs/free.txt $SEAFILEDIR/Logs/StoredLogs/${i}x4000B-free.txt
	rm $SEAFILEDIR/Logs/operf-ccnet_pid.txt $SEAFILEDIR/Logs/operf-seaf_pid.txt $SEAFILEDIR/Logs/top-iotop_pid.txt $SEAFILEDIR/Logs/free_pid.txt
	# free memory on c157 by running seaf-gc.sh over ssh and clear pagecache on client
	$SEAFILEDIR/TestScripts/SF-server-remote-restart.exp
	sync
	sh -c 'echo 3 > /proc/sys/vm/drop_caches'
done
echo "" >> $SEAFILEDIR/Logs/all-times.txt # newline

# test 10000 x 10B files to see if seafile syncs partial blocks
echo "Testing 10000 x 10B files"
echo "10000 x 10B completion time in nanoseconds" >> $SEAFILEDIR/Logs/all-times.txt
$SEAFILEDIR/TestScripts/sync-empty-folder.sh
python $SEAFILEDIR/TestScripts/maketree.py 10001 1 0 10001 0 10 $SEAFILEDIR/SeaFileLibraries/
# clear page cache to ensure new files are not still in memory
sync
sh -c 'echo 3 > /proc/sys/vm/drop_caches'
$SEAFILEDIR/TestScripts/sync-and-time.sh
mv $SEAFILEDIR/Logs/top.txt Logs/StoredLogs/10000x10B-top.txt
mv $SEAFILEDIR/Logs/iotop.txt Logs/StoredLogs/10000x10B-iotop.txt
mv $SEAFILEDIR/Logs/free.txt Logs/StoredLogs/10000x10B-free.txt
rm $SEAFILEDIR/Logs/operf-ccnet_pid.txt $SEAFILEDIR/Logs/operf-seaf_pid.txt $SEAFILEDIR/Logs/top-iotop_pid.txt $SEAFILEDIR/Logs/free_pid.txt
# free memory on c157 by running seaf-gc.sh over ssh and clear pagecache on client
$SEAFILEDIR/TestScripts/SF-server-remote-restart.exp
sync
sh -c 'echo 3 > /proc/sys/vm/drop_caches'
echo "" >> $SEAFILEDIR/Logs/all-times.txt # newline

# test a range of sizes for 1000 files
for i in `seq 1 1 10`;
do
	j=$((2**i))
	echo "Testing 1000 x $((j * 4))kB files"
	echo "1000 x $((j * 4))kB completion time in nanoseconds" >> $SEAFILEDIR/Logs/all-times.txt
	$SEAFILEDIR/TestScripts/sync-empty-folder.sh
	python $SEAFILEDIR/TestScripts/maketree.py 1001 1 0 1001 0 $((j * 4000)) $SEAFILEDIR/SeaFileLibraries/
	# clear page cache to ensure new files are not still in memory
	sync
	sh -c 'echo 3 > /proc/sys/vm/drop_caches'
	$SEAFILEDIR/TestScripts/sync-and-time.sh
	mv $SEAFILEDIR/Logs/top.txt Logs/StoredLogs/1000x$((j * 4000))B-top.txt
	mv $SEAFILEDIR/Logs/iotop.txt Logs/StoredLogs/1000x$((j * 4000))B-iotop.txt
	mv $SEAFILEDIR/Logs/free.txt Logs/StoredLogs/1000x$((j * 4000))B-free.txt
	rm $SEAFILEDIR/Logs/operf-ccnet_pid.txt $SEAFILEDIR/Logs/operf-seaf_pid.txt $SEAFILEDIR/Logs/top-iotop_pid.txt $SEAFILEDIR/Logs/free_pid.txt
	# free memory on c157 by running seaf-gc.sh over ssh and clear pagecache on client
	$SEAFILEDIR/TestScripts/SF-server-remote-restart.exp
	sync
	sh -c 'echo 3 > /proc/sys/vm/drop_caches'
done
