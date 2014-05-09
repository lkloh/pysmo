#!/bin/bash
#
# File: sodiccs.sh
#
# Run automatic iccstack with pickle files for pickle directories like ta2011q1mw60pkl
#
### xlou 11/14/2011

if [ $# -eq 0 ]; then
	echo "Usage: $0 pkldir1(ta2005q1mw60pkl) pkldir2(ta2005q2mw60pkl) ..."
	exit
fi

zipmode=gz

minqual=1
minnsel=10
ipick=t0
wpick=t1


for dir in $*; do
	cd $dir
	pwd

	# loop over event
	for bh in bhz bht; do
		echo $bh
		for evpkl in `ls [1-9]*$bh.pkl.$zipmode`; do
			echo $evpkl
			iccs.py $evpkl -a -q $minqual -n $minnsel -i $ipick -w $wpick
		done
	done

	if [ $dir != '.' ]; then
		cd ..
	fi
done

