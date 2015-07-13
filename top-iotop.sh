#!/bin/bash

# generate one report
top -b -n 1 | grep 'seaf-daemon\|ccnet' >> /home/william-kingsford/Logs/top.txt
iotop -b -n 1 | grep 'seaf-daemon\|ccnet' >> /home/william-kingsford/Logs/iotop.txt
