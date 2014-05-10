#!/bin/bash
#
# Plot station map or delay times if -d option is given.
#
### xlou 11/25/2011 || TREV Updated 03/05/14

#gmtset FONT_LABEL 10p,Helvetica,black # gmt5
gmtset FONT_LABEL 10p
gmtset FONT_ANNOT_PRIMARY 10p
gmtset FONT_ANNOT_SECONDARY 8p
gmtset FONT_TITLE	14p


if [ $# -eq 0 ]; then
        echo "Usage: $0 ifile (loc.sta or dtfile) title options"
		echo "       -d (delay time file) "
		echo "       -t (topo) -f (fillocean) "
		echo "       -g (geological provinces) -p (physio provinces) "
		echo "       -n (name of station) "
        exit
fi

#ihome=/Users/trevor/WORK/courses/499vdl/crustcorr
#ihome=/opt/local/seismo
ifile=$1
if [ $# -ge 2 ]; then
	tag=`echo $2 | cut -c1`
	if [ $tag == "-" ]; then
		title=$ifile
	else
		title=$2
	fi
else
	title=$ifile
fi

echo "ifile: $ifile"
echo "title: $title"

plottopo=F
fillocean=F
plotdelay=F
sdelay=F
plotgeov=F
plotphysio=F
plotsname=F

fig="$ifile".eps

for opt in $* ; do
	if  [ $opt == "-n" ]; then
		plotsname=T
		echo "Plot station name"
	fi
	if  [ $opt == "-t" ]; then
		plottopo=T
		echo "Plot topography"
	fi
	if  [ $opt == "-g" ]; then
		plotgeov=T
		echo "Plot geological provinces"
	fi
	if  [ $opt == "-p" ]; then
		plotphysio=T
		echo "Plot physiographic provinces"
	fi
	if  [ $opt == "-f" ]; then
		fillocean=T
		echo "Fill ocean"
	fi
	if  [ $opt == "-d" ]; then
		plotdelay=T
		fig=$ifile.eps
		flen=`echo $ifile | wc -c`
		flen1=`echo "$flen-1" |bc`
		phase=`echo $ifile | cut -c $flen1-$flen1`
	fi
	if  [ $opt == "-s" ]; then
		sdelay=T
	fi
done


#reg=-130/20/-60/53r
#proj=S-95/0/16c

reg=-125/25/-25/77r
proj=S-92/0/16c
psbasemap -R$reg -J$proj -B10f5:."$title":WSEn -X3 -Y12 -K -P > $fig
pscoast -R -J -G222 -Di -K -P -O >> $fig

### topo
etopo=$ihome/topo/etopo2.grd
#etopo=$ihome/data/topo/ETOPO2v2c_f4.nc
grd=$ihome/topo/us.grd
igrd=$ihome/topo/etopo2cut.grd
tcpt=/Users/trevor/scripts/cpt/topogray.cpt
tcpt=/Users/trevor/scripts/cpt/nice6.cpt
if [ ! -e $grd ]; then
	grdcut $etopo -R$reg -G$grd -fg
fi
if [ ! -e $igrd ]; then
	grdgradient $grd -Ne0.5 -A0 -M -G$grd
fi
if [ $plottopo == T ]; then
	grdimage $grd -I$igrd -C$tcpt -R -J -K -P -O  >>$fig
fi

### fill lakes and oceans with slate gray:185/211/238
if [ $fillocean == T ]; then 
	pscoast -R -J -A500 -W1.0 -K -Di -P -O -C185/211/238 -S185/211/238  >> $fig
fi
pscoast -R -J -A500 -W0.5 -K -P -Di -O -N1/0.7p -N2/.3p -N3/.1p >> $fig


### tectonic provinces
phys=/opt/local/seismo/data/GeolProv
prov=$phys/physio/cordillera.xy
physio=$phys/physio/physio_provinces.xy
pcolor=1p,magenta
pcolor2=.5p,magenta
if [ $plotgeov == T ]; then
	cat $prov | psxy -R -J -K -P -O -W$pcolor >> $fig
fi
if [ $plotphysio == T ]; then
	cat $physio | psxy -R -J -K -P -O -W$pcolor >> $fig
fi

### plot stations or color-coded by delays
#cpt=/Users/trevor/scripts/cpt/polarplus.cpt
if [ $plotdelay == F ]; then
	echo "Plot station loc file: $ifile --> $fig"
	if [ $plotsname == F ]; then
		symb=t.14
		stcol=red
		cat $ifile | awk '{print $3,$2}' | psxy -R -J -K -P -O -S$symb -G$stcol -W.1p,black >> $fig 
	else
		symb=t.07
		stcol=red
		cat $ifile | awk '{print $3,$2}' | psxy -R -J -K -P -O -S$symb -G$stcol -W.1p,black >> $fig 
		cat $ifile | cut -c 5-200 | awk '{print $3, $2, 2.5, 0, 2, "BC", $1}' | pstext -R -J -K -P -O -N >> $fig
	fi
else
	echo "Plot delay time file: $ifile --> $fig  (Phase: $phase)"

#	if [ -f $ifile-avstd ]; then
#		std=`awk '{printf"%.2f",$2}' $ifile-avstd`
#		dtm=`awk '{printf"%.2f",-$1}' $ifile-avstd`
#		phs=`echo $phase | tr "[:lower:]" "[:upper:]"`
#		text="@%12%\163@~@-$phs@- = $std s"
#		echo "plotting delay std: $text"
#		echo "-93 25 12 0 0 BL $text " | pstext -R -J -K -P -O -N >> $fig
#	fi
#	# plus/minus of the dt mean
#	pm=`echo $dtm | cut -c1`
#	if [ $pm == '-' ]; then
#		dtm=`echo $dtm | cut -c2-6`
#	else
#		pm="+"
#	fi
	dtm=0.00
	if [ $phase == 'p' ]; then
		#dt1=-0.6; dt2=0.6; dt=0.3
		dt1=-1.5; dt2=1.5; ddt=0.5
		if [ $dtm == '0.00' ] ; then
			label="P Delay [s]"
		else
			label="P Delay $pm $dtm [s]"
		fi
	else
		dt1=-2; dt2=2; dt=1
		dt1=-4.5; dt2=4.5; ddt=1.5
		if [ $dtm == '0.00' ] ; then
			label="S Delay [s]"
		else
			label="S Delay $pm $dtm [s]"
		fi
		#label='S Delay [s]'
	fi
	makecpt -Cpolar -T"$dt1/$dt2/$ddt" -Z -V -N > $cpt
	echo "label: $label"
	symb=c.14
#cat << eoi >> $cpt
#B 0   0   205
#F 170 0   0
#N 128 128 128
#eoi

cat $ifile | awk '{print $3,$2,$4}' |psxy -R -J -C$cpt -S$symb -K -P -O -V -N >> $fig
psscale -D13.95/3/5/0.2 -B.2:"$label": -C$cpt -O -X.25 -K -E >> $fig



fi

echo 0 0 | psxy -R -J -P -O >> $fig

ps2raster -Tg -A $fig
if [ $plotsname == T ]; then
	ps2raster -Tf -A $fig
fi

rm -f $fig 
#rm -f $cpt
rm -f .gmtcommands* .gmtdefaults* gmt.conf gmt.history


