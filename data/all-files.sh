#!/bin/bash

if [ "$1" == "" ]
then
	echo "Argument must be either free, top or iotop"
	exit
fi

for p in *B-$1.txt
do
	echo $p > name.txt
	sed "s/....$//" name.txt
	echo $p
	./sum-$1.sh "$(< name.txt)"
done
