#!/bin/bash

# report iostat data until either process is killed or 5 mins have elapsed
for i in `seq 1 3000`
do
	date +%Y-%m-%d-%H-%M-%S-%N
	iostat -x
	sleep 0.1
done
