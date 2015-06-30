#!/bin/bash

# get the 10th word of each row from file which is the first argument, 
awk '{ print $10 }' ${1}  > ${1}-io-used.txt

ioused=0
while read p; do
  tmp=`echo ${p//./}|sed 's/^0*//'` # remove decimal point and any leading zeroes
  ioused=$[ioused+tmp]
done <${1}-io-used.txt

echo ${ioused}


