#!/bin/bash

start=$(date +%s%N)
# start tracking detailed cpu/io data every second, running in background
# nohup is necessary to run a process in the background through ssh without hangups
nohup iostat -t -x 1 > /home/william-kingsford/Logs/iostat.txt 2>&1&
echo $! > /home/william-kingsford/Logs/iostat_pid.txt

# upload files
seaf-cli start
echo "Starting sync..."
seaf-cli sync -l b10d5f2a-9099-439a-abc4-dcdbfebf58e1 -s http://142.150.234.157:8001 -d /home/william-kingsford/SeaFileLibraries/ -u will.kingsford@gmail.com -p *hLO8GeH

# run until sync is complete
echo "About to check for sync completion..."
while seaf-cli status > /home/william-kingsford/Logs/status.txt; [ $(awk 'END { print $(NF) }' /home/william-kingsford/Logs/status.txt) = "synchronized" ]
do :;
done
echo "Sync completed"

finish=$(($(date +%s%N)-$start))
# end iostat process
kill -9 `cat /home/william-kingsford/Logs/iostat_pid.txt`

# desync library for future tests
echo "Desyncing library"
seaf-cli desync -d /home/william-kingsford/SeaFileLibraries/
seaf-cli stop

# print time taken
echo "time taken (in nanoseconds):" $finish
