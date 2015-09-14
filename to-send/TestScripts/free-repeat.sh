#!/bin/bash

# report free data every 100ms until either process is killed or 15 mins have elapsed
for i in `seq 1 9000`
do
	# get current memory usage (MB)
	free | awk 'NR % 4 - 2 == 0' | awk '{ print $3 }'
	sleep 0.1
done
