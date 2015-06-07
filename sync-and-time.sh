#!/bin/bash

start=$(date +%s%N)
# start tracking detailed cpu/io data every second, running in background
# nohup is necessary to run a process in the background through ssh without hangups
nohup iostat -t -x 1 > /home/william-kingsford/Logs/iostat.txt 2> /home/william-kingsford/Logs/iostat-errors.txt < /dev/null &

# upload files
seaf-cli start
seaf-cli sync -l b10d5f2a-9099-439a-abc4-dcdbfebf58e1 -s http://142.150.234.157:8001 -d /home/william-kingsford/SeaFileLibraries/ -u will.kingsford@gmail.com -p *hLO8GeH

# run until sync is complete
while seaf-cli status > /home/william-kingsford/Logs/status.txt; $(awk '{ END $(NF) }' /home/william-kingsford/Logs/status.txt)="synchronized" do :; done

finish=$(($(date +%s%N)-$start))
# end iostat process
kill %1

# desync library for future tests
seaf-cli desync -d /home/william-kingsford/SeaFileLibraries/

# print time taken
echo "time taken (in nanoseconds):" $finish
