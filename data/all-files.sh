#!/bin/bash

for i in "free" "top" "iotop"
do	
	for p in $(ls *B-$i.txt)
	do
		echo $p > name.txt
		sed "s/....$//" name.txt
		echo $p
		./sum-$i.sh "$(< name.txt)"
	done
done
