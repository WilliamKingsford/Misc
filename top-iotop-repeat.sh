#!/bin/bash

# report top + iotop data until either process is killed or 5 mins have elapsed
for i in `seq 1 3000`
do
	# background process for each iteration so it is done 10x a second rather than ~7.5x due to execution time
	nohup /home/william-kingsford/Misc/top-iotop.sh > /dev/null 2>&1&
	sleep 0.1
done
