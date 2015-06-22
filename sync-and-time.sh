#!/bin/bash

echo "sync-and-time.sh: Starting seaf-cli"
seaf-cli start
#sleep 3

start=$(date +%s%N)
# start tracking detailed cpu/io data every 0.1 second, running in background
# nohup is necessary to run a process in the background through ssh without hangups
nohup /home/william-kingsford/Misc/iostat-repeat.sh > /home/william-kingsford/Logs/iostat.txt 2>&1&
echo $! > /home/william-kingsford/Logs/iostat_pid.txt

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
# end iostat process
kill -15 `cat /home/william-kingsford/Logs/iostat_pid.txt`

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
