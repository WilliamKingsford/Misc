#!/bin/bash
#Script to generate directories of random files then test how long SeaFile spends
#syncing them.

# checks if seaf-cli is already running
RUNNING=`ps cax | grep seaf-cli | grep -o '^[ ]*[0-9]*'`
if [ -z "$RUNNING" ]; then
	echo "Please start seaf-cli before running this script."
	echo "Ensure that the synced folder is empty both locally and online."
	exit 1
else
	# Performs upload tests
	for i in 'seq 1 50'; do
		# **** SET LOCATION ****
		python maketree.py 200*$i 1 0 200*$i 0 4000 '*****'
		# Sync to SeaFile
		seaf-cli sync # arguments
		
		# Waits until sync is complete
		until [ `seaf-cli status` -ne "***OUTPUT***" ]; do # **** FIND CORRECT OUTPUT ****
			echo "Syncing..."
			sleep 1
		done
		# Move addition logfile
		mv /home/william-kingsford/TimerLogs/*** /home/william-kingsford/TimerLogs/Addition/addition-$i
		
		# Empty library on SeaFile and locally
		rm -rf *******
		seaf-cli sync # arguments
		# Move deletion logfile
		mv /home/william-kingsford/TimerLogs/*** /home/william-kingsford/TimerLogs/Deletion/deletion-$i;
	done
	
	# Adds up times to completion
	for i in 'seq 1 50'; do
		# Adds times to completion for each file
		python addtimes.py addition-$i '/home/william-kingsford/TimerLogs/Addition/' addition
		python addtimes.py deletion-$i '/home/william-kingsford/TimerLogs/Deletion/' deletion;
	done
fi
