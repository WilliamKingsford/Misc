#!/bin/bash

echo "Starting seaf-cli and giving it 10 seconds to load"
seaf-cli start
sleep 10

start=$(date +%s%N)
# start tracking detailed cpu/io data every second, running in background
# nohup is necessary to run a process in the background through ssh without hangups
nohup iostat -t -x 1 > /home/william-kingsford/Logs/iostat.txt 2>&1&
echo $! > /home/william-kingsford/Logs/iostat_pid.txt

# upload files
echo "Starting sync..."
seaf-cli sync -l b10d5f2a-9099-439a-abc4-dcdbfebf58e1 -s http://142.150.234.157:8001 -d /home/william-kingsford/SeaFileLibraries/ -u will.kingsford@gmail.com -p *hLO8GeH

# run until sync is complete
continue="1"
echo "About to check for sync completion (adding files)..."
while [ "$continue" -eq "1" ]
do
seaf-cli status > /home/william-kingsford/Logs/status.txt
sleep 1
if [ $(awk 'END { print $(NF) }' /home/william-kingsford/Logs/status.txt) = "synchronized" ]
then continue="0"
else echo "Checking..."
fi
done

echo "Sync completed"

finish=$(($(date +%s%N)-$start))
# end iostat process
kill -9 `cat /home/william-kingsford/Logs/iostat_pid.txt`

# empty and desync library for future tests
echo "Emptying library"
rm /home/william-kingsford/SeaFileLibraries/*

# run until sync is complete
continue="1"
echo "About to check for sync completion (removing files)..."
while [ "$continue" -eq "1" ]
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
