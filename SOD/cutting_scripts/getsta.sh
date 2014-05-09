#!/bin/bash
#
# Get loc.sta from each of input dirs (which are from getsta.py) to get a uniq one.
#
### xlou 11/26/2011

if [ $# -eq 0 ]; then
	echo "Usage: $0 dir1(ta2005q1mw60) dir2(ta2005q2mw60) ..."
	exit
fi

sfile=loc.sta

tmpfile=tmpfile
rm -f $tmpfile

for dir in $*; do
	echo "Get $dir/$sfile"
	cat $dir/$sfile >> $tmpfile
done

sort $tmpfile | uniq > $sfile
echo "--> Save as an uniq $sfile."

rm -f $tmpfile

