#!/bin/bash

# Restarts Seafile when run on the server side, runs Seafile's garbage collection script
# and clears cache before starting again.

cd /home/william-kingsford/SeaFileServer/seafile-server-4.1.2/
./seafile.sh stop
./seahub.sh stop
sleep 1
./seaf-gc.sh
sync
sh -c 'echo 3 > /proc/sys/vm/drop_caches'
./seafile.sh start
./seahub.sh start 8001
