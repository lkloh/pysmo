#!/bin/bash
#
# File: autoiccs.sh
#
# Run automatic iccstack with pickle files for pickle directories like ta2011q1mw60pkl
#
### xlou 11/14/2011

if [ $# -eq 0 ]; then
	echo "Usage: $0 pkldir1(ta2005q1mw60pkl) pkldir2(ta2005q2mw60pkl) ..."
	exit
fi


minnsel=5
minccc=0.5
minsnr=0.5
mincoh=0.1

zipmode=gz
ipick=t0
wpick=t1


for dir in $*; do
	cd $dir
	echo "###"
	pwd

	# loop over event
	for bh in bhz bht; do
		echo $bh
		if [ $bh == bhz ]; then
			tw0=-15
			tw1=15
		else
			tw0=-25
			tw1=25
		fi
		for evpkl in `ls [1-9]*$bh".pkl"`; do
			echo iccs.py $evpkl -a -q $minqual -n $minnsel -i $ipick -w $wpick -t $tw0 $tw1
			echo y | iccs.py $evpkl -a -q $minccc $minsnr $mincoh -n $minnsel -i $ipick -w $wpick -t $tw0 $tw1
		done
	done

	if [ $dir != '.' ]; then
		cd ..
	fi
done

