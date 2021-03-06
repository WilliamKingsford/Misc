#!/bin/bash

# check if running as root (needed for iotop)
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "sync-and-time.sh: Starting seaf-cli"
seaf-cli start > /dev/null 2>&1&
# start tracking with OProfile
#nohup operf --pid `ps -ef | grep 'ccnet --daemon' | awk 'NR % 2 - 1 == 0' | awk '{ print $2 }'` > /home/william-kingsford/Logs/ccnet-operf.txt 2>&1&
#echo $! > /home/william-kingsford/Logs/operf-ccnet_pid.txt
#nohup operf --pid `ps -ef | grep 'seaf-daemon' | awk 'NR % 2 - 1 == 0' | awk '{ print $2 }'` > /home/william-kingsford/Logs/seaf-operf.txt 2>&1&
#echo $! > /home/william-kingsford/Logs/operf-seaf_pid.txt

start=$(date +%s%N)
# start tracking detailed cpu/io data every 0.1 second, running in background
# nohup is necessary to run a process in the background through ssh without hangups
nohup /home/william-kingsford/Misc/top-iotop-repeat.sh > /dev/null 2>&1&
echo $! > /home/william-kingsford/Logs/top-iotop_pid.txt
nohup /home/william-kingsford/Misc/free-repeat.sh > /home/william-kingsford/Logs/free.txt 2>&1&
echo $! > /home/william-kingsford/Logs/free_pid.txt

# upload files
echo "Starting sync..."
#seaf-cli sync -l 4915ec59-c414-47d1-a14e-ed290339172b -s http://142.150.234.157:8001 -d /home/william-kingsford/SeaFileLibraries/ -u will.kingsford@gmail.com -p *hLO8GeH

# run until sync is complete
continue="1"
echo "About to check for sync completion (adding files)..."
while [[ "$continue" -eq "1" ]]
do
seaf-cli status > /home/william-kingsford/Logs/status.txt
# write sync status to file to find when sync begins
#date +%Y-%m-%d-%H-%M-%S-%N >> /home/william-kingsford/Logs/status-messages.txt
#awk 'END { print $(NF) }' /home/william-kingsford/Logs/status.txt >> /home/william-kingsford/Logs/status-messages.txt
sleep 0.1
if [[ $(awk 'END { print $(NF) }' /home/william-kingsford/Logs/status.txt) = "synchronized" ]]
then continue="0"
else echo "Checking..."
fi
done

echo "Sync completed"

finish=$(($(date +%s%N)-$start))
# end operf, top-iotop and free processes
#kill -15 `cat /home/william-kingsford/Logs/operf-ccnet_pid.txt`
#kill -15 `cat /home/william-kingsford/Logs/operf-seaf_pid.txt`
kill -15 `cat /home/william-kingsford/Logs/top-iotop_pid.txt`
kill -15 `cat /home/william-kingsford/Logs/free_pid.txt`

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
