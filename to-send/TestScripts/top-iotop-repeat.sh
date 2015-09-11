#!/bin/bash

# This script reports top + iotop data until either process is killed or 15 mins have elapsed

# checks for environment variable for SeaFileLibraries & Logs location, if not defined it's
# assumed the location of these folders is ~
if ! [[ $SEAFILEDIR ]]
then
	SEAFILEDIR=~
fi

for i in `seq 1 9000`
do
	# background process for each iteration so it is done 10x a second rather than ~7.5x due to execution time
	nohup $SEAFILEDIR/TestScripts/top-iotop.sh > /dev/null 2>&1&
	sleep 0.1
done
