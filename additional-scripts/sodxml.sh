#!/bin/bash
#
# Make multiple sod recipe xml files from given input standard file by replacing date and magnitude tags.
#
### xlou 10/20/2011


# input example file with date begin/end and magnitude min/max.
ifile=base_ta2011q1mw60.xml
date0=2011-01-01
date1=2011-03-31
mag0=6.0
mag1=9.9

# date begin/end for each quarter of year
qtrs=(1 2 3 4)
dbeg=(01-01 04-01 07-01 10-01)
dend=(03-31 06-30 09-30 12-31)

# magnitude min/max
mws=(50 55 60)
mmin=(5.0 5.5 6.0)
mmax=(5.4 5.9 9.9)

# years
years=`seq 2005 2011`

for yr in $years; do
	yrdir=ta$yr
	if [ ! -e $yrdir ]; then
		mkdir $yrdir
	fi
	for q in `seq 0 3`; do
		echo $yr - quarter ${qtrs[$q]}
		for m in `seq 0 2`; do
			mdir=ta"$yr"q"${qtrs[$q]}"mw"${mws[$m]}"
			mkdir $yrdir/$mdir
			sed "s/$date0/$yr-${dbeg[$q]}/g" $ifile | sed "s/$date1/$yr-${dend[$q]}/g" | sed "s/<min>$mag0/<min>${mmin[$m]}/g" | sed "s/<max>$mag1/<max>${mmax[$m]}/g" > $yrdir/$mdir/$mdir.xml
		done
	done
done


