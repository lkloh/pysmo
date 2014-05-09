#!/bin/bash
#
# Redo sodpkl.sh
# 	unzip sac.tar.gz
#
### xlou 11/14/2011

if [ $# -eq 0 ]; then
	echo "Usage: $0 soddir1(ta2005q1mw60) soddir2(ta2005q2mw60) ..."
	exit
fi

sdir=sac

delta=0.025

logfile=sodpkl2.log

for dir in $*; do
	cd $dir
	pwd
	log=`pwd`/$logfile
	pwd >& $log
	# gunzip, untar sac files
	if [ ! -d $sdir ]; then
		gunzip $sdir.tar.gz
		tar zxvf $sdir.tar
	fi


	# loop over event
	for evdir in `ls -d $sdir/Event_*`; do 
		evdate=`echo $evdir | cut -d/ -f2 | cut -d_ -f2 | awk -F. '{print $1$2$3"."$4$5$6$7}' | cut -c1-17`
		echo "$evdir --> $evdate" >> $log 2>&1
# filter
sac << eoi
r $evdir/*Z
bp co .03 2 P 2 
w over
r $evdir/*T
bp co .03 2 P 2
w over
quit
eoi

		sac2pkl.py $evdir/*BHZ -o $evdate.bhz.pkl -d $delta -z gz >> $log 2>&1 
		sac2pkl.py $evdir/*BHT -o $evdate.bht.pkl -d $delta -z gz >> $log 2>&1 
	done
	cd ..
done

