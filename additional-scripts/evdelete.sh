#!/bin/bash
# Delete events with less than 5 traces.
### xlou 03/20/2012


if [ $# -eq 0 ]; then
	echo "Usage: $0 mintrace"
	exit
fi

mint=$1
tdir=trash
if [ ! -d $tdir ]; then
	mkdir $tdir
fi

echo "Delete events with less than $mint traces.."
for dir in `ls -d Event_*`; do
	nz=`ls $dir/*Z.sac | wc -l`
	if [ $nz -lt $mint ]; then
		echo "mv $dir $tdir"
		mv $dir $tdir
	fi
done

