#!/bin/bash

# get the 5th row out of each set of 9 from file which is the first argument, 
# then get the 6th word of each row that's been selected (the idle cpu %)
awk 'NR % 9 - 5 == 0' ${1}.txt | awk '{ print $6 }' > ${1}-cpu-free.txt

cpuused=0
while read p; do
  tmp=$(expr 10000 - ${p//./}) # remove decimal point and subtract this from 10000 to get used cpu
  cpuused=$[cpuused+tmp]
done <${1}-cpu-free.txt

echo ${cpuused}


