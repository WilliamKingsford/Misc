#!/bin/bash

for p in *.txt
do
	echo $p
	awk '{s+=$1} END {print s}' $p > $p-sum.txt
done
