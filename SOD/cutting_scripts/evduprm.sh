#!/bin/bash
# Remove duplicate events: rm pkl
### xlou 11/20/2011


if [ $# -eq 0 ]; then
	echo "Usage: $0 evdir1 evdir2 evdir3.."
	exit
fi

sacdir=sac
dupdir=sacdup

evback=evlist.back
evlist=evlist

for dir in $*; do 
	cd $dir
	pwd
	rm -f $evlist

	echo "dup ev"
	for evdir in `ls -d $dupdir/Event_*`; do 
		evdate=`echo $evdir | cut -d/ -f2 | cut -d_ -f2 | awk -F. '{print $1$2$3"."$4$5$6$7}' | cut -c1-17`
		echo $evdate 
		mv $evdate*pkl* $dupdir
	done

	echo "good ev"
	for evdir in `ls -d $sacdir/Event_*`; do 

		evtime=` echo $evdir | cut -d/ -f2 | cut -d_ -f2 | awk -F. '{print $1"/"$2"/"$3" "$4":"$5":"$6"."$7}'`
		echo $evtime
		grep "$evtime" $evback >> $evlist
	done

	cd ..
done

