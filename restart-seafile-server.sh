#!/bin/bash

cd /home/william-kingsford/SeaFileServer/seafile-server-4.1.2/
GMON_OUT_PREFIX="mygmon" ./seafile.sh stop
GMON_OUT_PREFIX="mygmon" ./seahub.sh stop
sleep 1
# rename gmon.out so it's not overwritten
mv gmon.out gprof/gmon.out-$(date +'%Y-%m-%d-%R')
./seaf-gc.sh
sh -c 'echo 1 > /proc/sys/vm/drop_caches'
GMON_OUT_PREFIX="mygmon" ./seafile.sh start
GMON_OUT_PREFIX="mygmon" ./seahub.sh start 8001
