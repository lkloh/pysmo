#!/bin/bash
#
# Keep processed seismograms from SOD, and run cutevseis.sh to
#    set SAC header variables and cut seismograms.
# Save log to each directory.
#
### xlou 11/14/2011

if [ $# -eq 0 ]; then
	echo "Usage: $0 soddir1(ta2005q1mw60) soddir2(ta2005q2mw60) ..."
	exit
fi

sdir=processedSeismograms
ddir=seismograms
odir=sac

logfile=sodcut.log

for dir in $*; do
	cd $dir
	log=`pwd`/$logfile
	pwd
	pwd >& $log
	
	# remove not necessary files, rename seis dir to sac
	rm -rf Fail.log Sod* $ddir
	if [ -d $sdir ]; then
		mv $sdir $odir
		mv *xml $odir
	fi
	cd $odir

	# loop over event
	for evdir in `ls -d Event_*`; do 
		cd $evdir
		pwd
		pwd >> $log 2>&1
	
		# remove data with gaps (sod failed to remove these seismograms)
		for fname in `ls *Z.sac.1`; do
			netsta=`echo $fname | cut -d. -f1-2`
			rm *$netsta*
		done

		# set sac hdr and cut
		cutevseis.sh  >> $log 2>&1

		cd ..	
	done

	cd ../..
done

