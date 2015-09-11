#!/bin/bash

# report free data every 100ms until either process is killed or 15 mins have elapsed
for i in `seq 1 9000`
do
	free
	sleep 0.1
done
