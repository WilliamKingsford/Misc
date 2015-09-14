#!/bin/bash

# generate one top & iotop report

# checks for environment variable for SeaFileLibraries & Logs location, if not defined it's
# assumed the location of these folders is ~
if ! [[ $SEAFILEDIR ]]
then
	SEAFILEDIR=~
fi

# get current cpu usage %
top -b -n 1 | grep 'seaf-daemon\|ccnet' | awk '{ print $9 }' >> $SEAFILEDIR/Logs/top.txt
# get current io usage %
iotop -b -n 1 | grep 'seaf-daemon\|ccnet' | awk '{ print $10 }' >> $SEAFILEDIR/Logs/iotop.txt
