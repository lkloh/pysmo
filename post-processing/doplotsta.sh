#!/bin/bash
#
# Run plotsta.sh for multiple delay files
# Now also does relative and absolute (.dtp and .adtp) delay files
#
### xlou 11/25/2011 || TREV Updated 03/05/14


dtfiles=`ls [1-9]*.dt?`
echo $dtfiles
for dtfile in $dtfiles; do
	plotsta.sh $dtfile -d -t
done

phase=`echo $dtfiles | cut -d" " -f 1 | cut -d. -f3 | cut -c 3`

figs=`ls [1-9]*.dt$phase.png`
echo convert $figs dt$phase.gif
convert $figs dt$phase.gif
rm -f $figs

adtfiles=`ls [1-9]*.adt?`
echo $adtfiles
for adtfile in $adtfiles; do
	plotsta.sh $adtfile -d -t
done

phase=`echo $adtfiles | cut -d" " -f 1 | cut -d. -f3 | cut -c 4`

figs=`ls [1-9]*.adt$phase.png`
echo convert $figs adt$phase.gif
convert $figs adt$phase.gif

rm -f $figs
rm -f .gmtdefaults .gmtcommands
