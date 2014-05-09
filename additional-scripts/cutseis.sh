#!/bin/bash
# Cut seismograms in a time window around a time pick (tpick+tw1, tpick+tw2).
# Save as a shorter file name: TA.109C.__.BHZ.sac --> TA.109C.__.BHZ
### xlou 11/14/2011 

if [ $# -ne 4 ];  then
	echo "Usage: $0 filename_extention(BHZ.sac) tpick tw1 tw2"
	exit
fi

comp=$1
tpick=$2
tw1=$3
tw2=$4

for sacf in `ls *$comp`; do
#sacfnew=`echo $sacf | tr "[:upper:]" "[:lower:]" | cut -d. -f 1-4`
sacfnew=`echo $sacf | cut -d. -f 1-4`
cp $sacf $sacfnew

sac << eoi
r $sacf
setbb t0 &1,$tpick
evaluate to t1 %t0 + $tw1
evaluate to t2 %t0 + $tw2
cut %t1 %t2
r $sacfnew
rmean
rtr
taper
w over
q
eoi

done

