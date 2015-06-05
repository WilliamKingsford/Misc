#!/bin/bash

start=$(date +%s%N)
# start tracking cpu/io data every second, running in background
iostat -t 1 > stats.txt &

# upload files
seaf-cli sync -l `cat lib-id.txt` -s http://192.168.216.119:8001 -d MyData/My\ Library/ -u will.kingsford@gmail.com -p *hLO8GeH

# run until sync is complete
while seaf-cli status > status.txt; $(awk '{ END $(NF) }' status.txt)="" do :; done

finish=$(($(date +%s%N)-$start))
# end iostat process
kill %1
