#!/bin/bash
#
# Run sod simutaneously or sequentially?
#
# Input directories which contain xml recipe with the same filename.
#
### xlou 10/26/2011

if [ $# -eq 0 ]; then
	echo "Usage: $0 dir1 dir2 ..."
	exit
fi

for dir in $*; do
	echo $dir
	cd $dir
	pwd
	rm -rf Fail.log Sod*
	#sod -f $dir.xml &
	sod -f $dir.xml
	cd ..
done

