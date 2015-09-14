#!/bin/bash

cpuused=0
while read p; do
  tmp=${p} 
  cpuused=$((cpuused+tmp))
done <${1}

echo ${1} "cpu used:" ${cpuused} >> top-list.txt
