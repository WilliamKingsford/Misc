#!/bin/bash

# test 1000 x 4000B files as baseline
echo "Testing 1000 x 4000B files"
/home/william-kingsford/Misc/sync-empty-folder.sh
python maketree.py 10001 1 0 10001 0 10 /home/william-kingsford/SeaFileLibraries/
rm gmon.out
# clear page cache to ensure new files are not still in memory
sync
sh -c 'echo 3 > /proc/sys/vm/drop_caches'
/home/william-kingsford/Misc/sync-and-time-profile.sh
mv /home/william-kingsford/Logs/top.txt Logs/StoredLogs/10000x10B-top.txt
mv /home/william-kingsford/Logs/iotop.txt Logs/StoredLogs/10000x10B-iotop.txt
mv /home/william-kingsford/Logs/free.txt Logs/StoredLogs/10000x10B-free.txt
rm /home/william-kingsford/Logs/operf-ccnet_pid.txt /home/william-kingsford/Logs/operf-seaf_pid.txt /home/william-kingsford/Logs/top-iotop_pid.txt /home/william-kingsford/Logs/free_pid.txt
# free memory on c157 by running seaf-gc.sh over ssh and clear pagecache on client
/home/william-kingsford/Misc/c157.exp
sync
sh -c 'echo 3 > /proc/sys/vm/drop_caches'
