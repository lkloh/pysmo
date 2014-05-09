#!/bin/bash
#
# kill sod/java process
#
### xlou 10/26/2011

for pid in `ps aux | grep $USER | grep java | awk '{print $2}'`; do
	echo $pid
	kill -9 $pid
done
