#!/bin/bash

# get the 9th word of each row from file which is the first argument, 
awk '{ print $9 }' ${1}  > ${1}-cpu-used.txt

cpuused=0
while read p; do
  tmp=${p} 
  cpuused=$[cpuused+tmp]
done <${1}-cpu-used.txt

echo ${cpuused}


