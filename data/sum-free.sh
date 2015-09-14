#!/bin/bash

used=0
while read p; do
  tmp=${p}
  used=$((used+tmp))
done <${1}

echo ${1} "memory:" ${used} >> free-list.txt
