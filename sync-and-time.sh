#!/bin/bash

start=$(date +%s%N)
# start tracking detailed cpu/io data every second, running in background
# nohup is necessary to run a process in the background through ssh without hangups
nohup iostat -t -x 1 > stats.txt 2> iostat-errors.txt < /dev/null &

# upload files
seaf-cli sync -l `cat lib-id.txt` -s http://192.168.216.119:8001 -d MyData/My\ Library/ -u will.kingsford@gmail.com -p *hLO8GeH

# run until sync is complete
while seaf-cli status > status.txt; $(awk '{ END $(NF) }' status.txt)="synchronized" do :; done

finish=$(($(date +%s%N)-$start))
# end iostat process
kill %1
