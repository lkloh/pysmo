#!/bin/bash
# Set theoretical arrival times to SAC header variables,
# and cut seismograms for an event.
#
### xlou 11/14/2011


mod=iasp91
tpick=0

taup_setsac -mod $mod -ph P-$tpick *BHZ.sac
taup_setsac -mod $mod -ph S-$tpick *BHT.sac

#tp0=-40; tp1=60
#ts0=-60; ts1=90
tp0=-40; tp1=60
ts0=-60; ts1=90

cutseis.sh BHZ.sac t$tpick $tp0 $tp1
cutseis.sh BHT.sac t$tpick $ts0 $ts1

rm *.sac
