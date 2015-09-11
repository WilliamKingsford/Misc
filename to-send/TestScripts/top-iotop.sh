#!/bin/bash

# generate one top & iotop report

# checks for environment variable for SeaFileLibraries & Logs location, if not defined it's
# assumed the location of these folders is ~
if ! [[ $SEAFILEDIR ]]
then
	SEAFILEDIR=~
fi

top -b -n 1 | grep 'seaf-daemon\|ccnet' >> $SEAFILEDIR/Logs/top.txt
iotop -b -n 1 | grep 'seaf-daemon\|ccnet' >> $SEAFILEDIR/Logs/iotop.txt
