#!/bin/bash

cd /home/william-kingsford/SeaFileServer/seafile-server-4.1.2/
./seafile.sh stop
./seahub.sh stop
sleep 1
./seafile.sh start
./seahub.sh start 8001
