#!/bin/bash
# Filter seismograms from an event by SAC and save to pickle.
#
### xlou 11/23/2011

if [ $# -ne 3  ]; then
	echo "Usage: $0 pklfile f0 f1"
	exit
fi

fmin=$2
fmax=$3

sdir=sac
delta=0.025

pkl=$1
year=`echo $pkl | cut -c 1-4`
mon=`echo $pkl | cut -c 5-6`
day=`echo $pkl | cut -c 7-8`
hour=`echo $pkl | cut -c 10-11`
min=`echo $pkl | cut -c 12-13`
sec=`echo $pkl | cut -c 14-15`
msec=`echo $pkl | cut -c 16-17`

evdir=`ls -d $sdir/Event_$year.$mon.$day.$hour.$min.$sec.$msec?`

bh=`echo $pkl | cut -d. -f3`
if [ $bh == 'bhz' ]; then
	comp=BHZ
else
	comp=BHT
fi

echo "Filter seismograms of $sdir/$evdir/*.$comp by  bp co $2 $3 P 2"


sac << eoi
r $evdir/*$comp
bp co $fmin $fmax P 2 
w over
quit
eoi
sac2pkl.py $evdir/*$comp -o $pkl -d $delta -s  

