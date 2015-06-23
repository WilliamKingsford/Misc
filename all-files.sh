#!/bin/bash

for p in *B.txt
do
	echo $p > name.txt
	sed "s/....$//" name.txt
	echo $p
	./sum-cpu-usage.sh "$(< name.txt)"
done
