#!/bin/bash

ioused=0
while read p; do
  tmp=`echo ${p//./}|sed 's/^0*//'` # remove decimal point and any leading zeroes
  ioused=$((ioused+tmp))
done <${1}

echo ${1} "io-used:" ${ioused} >> iotop-list.txt
