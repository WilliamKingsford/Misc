#!/bin/bash

# get the 2nd row out of each set of 4 from file which is the first argument, 
# then get the 3th word of each row that's been selected (the used memory)
awk 'NR % 4 - 2 == 0' ${1} | awk '{ print $3 }' > ${1}-mem-used.txt

used=0
while read p; do
  tmp=${p}
  used=$[used+tmp]
done <${1}-mem-used.txt

echo ${used}


