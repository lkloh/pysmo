#!/bin/bash
# Rotate EN components to RT
### xlou 03/14/2012 Pi Day

for bhz in `ls *BHZ.sac`; do
	bhe=`echo $bhz | sed 's/BHZ/BHE/g'`
	bhn=`echo $bhz | sed 's/BHZ/BHN/g'`
	bhr=`echo $bhz | sed 's/BHZ/BHR/g'`
	bht=`echo $bhz | sed 's/BHZ/BHT/g'`
	
	if [ -f $bhe -a -f $bhn ]; then
		echo  "rotate to gcp for $bhe $bhn"

sac << eoi
r $bhe $bhn
rot to gcp
w $bhr $bht
quit 
eoi

	fi
done


mod=iasp91
tpick=0

taup_setsac -mod $mod -ph P-$tpick *BHZ.sac
taup_setsac -mod $mod -ph S-$tpick *BHT.sac

