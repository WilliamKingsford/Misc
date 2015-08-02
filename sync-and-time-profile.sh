#!/bin/bash

# check if running as root (needed for iotop)
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# test for valid arguments
if [[ $# -eq 0 ]]
then echo "Syntax:"
echo "generating no files: sync-and-time-profile.sh 0"
echo "generating files:    sync-and-time-profile.sh 1 <# of files> <size of files (B)>"
exit
fi
if !( [[ $# -eq 1 ]] || [[ $# -eq 3 ]] )
then echo "Invalid number of arguments."
echo "Syntax:"
echo "generating no files: sync-and-time-profile.sh 0"
echo "generating files:    sync-and-time-profile.sh 1 <# of files> <size of files (B)>"
exit
fi
if [[ $# -eq 1 ]] && ![[ $1 -eq 0 ]]
then echo "Invalid arguments. If only one argument is given it must be 0 (generate no files)."
exit
fi
if ( [[ $# -eq 3 ]] && [[ !$1 -eq 1 ]] ) || ( [[ $1 -eq 1 ]] && ![[ $# -eq 3 ]] )
then echo "If the first argument is 1 then there must be 3 total arguments (1, number of files, size of files) and vice versa."
exit
fi

echo "EMPTY FOLDER PRE-SYNC: Starting seaf-cli and giving it 3 seconds to load"
seaf-cli start > /dev/null 2>&1&
sleep 3

echo "Starting sync..."
seaf-cli sync -l 4915ec59-c414-47d1-a14e-ed290339172b -s http://142.150.234.157:8001 -d /home/william-kingsford/SeaFileLibraries/ -u will.kingsford@gmail.com -p *hLO8GeH

# run until sync is complete
continue="1"
sleep 5
echo "About to check for sync completion (empty folder)..."
while [ "$continue" -eq "1" ]
do
seaf-cli status > /home/william-kingsford/Logs/status.txt
sleep 1
if [[ $(awk 'END { print $(NF) }' /home/william-kingsford/Logs/status.txt) = "synchronized" ]]
then continue="0"
else echo "Checking..."
fi
done

seaf-cli stop

echo "Sync completed with empty folder, removing old gmon.out"

# remove gmon.out produced by the pre-sync
rm gmon.out

# generate files for sync if first argument is 1
if [[ $1 -eq 1 ]]
then echo "Generating files" 
python maketree.py $(($2+1)) 1 0 $(($2+1)) 0 $3 /home/william-kingsford/SeaFileLibraries/
else echo "Test with no added files"
fi

echo "FILE SYNC: Starting seaf-cli"
seaf-cli start > /dev/null 2>&1&

start=$(date +%s%N)
# start tracking detailed cpu/io data every 0.1 second, running in background
# nohup is necessary to run a process in the background through ssh without hangups
nohup /home/william-kingsford/Misc/top-iotop-repeat.sh > /dev/null 2>&1&
echo $! > /home/william-kingsford/Logs/top-iotop_pid.txt
nohup /home/william-kingsford/Misc/free-repeat.sh > /home/william-kingsford/Logs/free.txt 2>&1&
echo $! > /home/william-kingsford/Logs/free_pid.txt

# upload files
echo "Starting sync..."

# run until sync is complete
continue="1"
echo "About to check for sync completion (adding files)..."
while [[ "$continue" -eq "1" ]]
do
seaf-cli status > /home/william-kingsford/Logs/status.txt
# write sync status to file to find when sync begins
sleep 0.1
if [[ $(awk 'END { print $(NF) }' /home/william-kingsford/Logs/status.txt) = "synchronized" ]]
then continue="0"
else echo "Checking..."
fi
done

echo "Sync completed"

finish=$(($(date +%s%N)-$start))
# end operf, top-iotop and free processes
kill -15 `cat /home/william-kingsford/Logs/top-iotop_pid.txt`
kill -15 `cat /home/william-kingsford/Logs/free_pid.txt`

# empty and desync library for future tests
echo "Emptying library"
rm /home/william-kingsford/SeaFileLibraries/*

# run until sync is complete
continue="1"
sleep 5
echo "About to check for sync completion (removing files)..."
while [[ "$continue" -eq "1" ]]
do
seaf-cli status > /home/william-kingsford/Logs/status.txt
sleep 1
if [ $(awk 'END { print $(NF) }' /home/william-kingsford/Logs/status.txt) = "synchronized" ]
then continue="0"
else echo "Checking..."
fi
done

echo "Desyncing library"
seaf-cli desync -d /home/william-kingsford/SeaFileLibraries/
seaf-cli stop

# print time taken
echo "time taken (in nanoseconds):" $finish
# write time taken to log file
echo "$finish" >> /home/william-kingsford/Logs/all-times.txt
