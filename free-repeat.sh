#!/bin/bash

# report free data until either process is killed or 5 mins have elapsed
for i in `seq 1 3000`
do
	free
	sleep 0.1
done
