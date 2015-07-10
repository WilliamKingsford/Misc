#!/bin/bash

# generate one report
top -b -n 1 > /home/william-kingsford/Logs/top-raw.txt
iotop -b -n 1 > /home/william-kingsford/Logs/iotop-raw.txt
# process that one report and delete raw output file
grep ccnet /home/william-kingsford/Logs/top-raw.txt >> /home/william-kingsford/Logs/top.txt
grep seaf-daemon /home/william-kingsford/Logs/top-raw.txt >> /home/william-kingsford/Logs/top.txt
grep ccnet /home/william-kingsford/Logs/iotop-raw.txt >> /home/william-kingsford/Logs/iotop.txt
grep seaf-daemon /home/william-kingsford/Logs/iotop-raw.txt >> /home/william-kingsford/Logs/iotop.txt
rm /home/william-kingsford/Logs/top-raw.txt
rm /home/william-kingsford/Logs/iotop-raw.txt
