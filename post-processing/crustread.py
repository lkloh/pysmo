#!/usr/bin/env python
"""
File: crustread.py

Script to get Moho depth from model: crust2, crust2intp, NA04, NA07, Lowry or a combination.

xlou 03/10/2012
"""

from pylab import *
import os, sys
from optparse import OptionParser
from ttcommon import readStation, saveStation, readPickle, writePickle
from ppcommon import plotcmodel, plotcoast, plotphysio
from crust import point_moho, find_moho, c2thick, point_c2thick, point_c2thick_intpol, point_c2model, point_c2model_intpol, refModel, meanModel


def getParams():
	""" Parse arguments and options from command line. 
	"""
	usage = "Usage: %prog [options] "
	parser = OptionParser(usage=usage)
	stafile = 'loc.sta'
	parser.set_defaults(stafile=stafile)
	parser.add_option('-m', '--model',  dest='model', type='str',
		help='Model from which to get Moho depths for stations.')
	parser.add_option('-s', '--stafile',  dest='stafile', type='str',
		help='Station location file. Default is {:s}'.format(stafile))
	parser.add_option('-c', '--c2model',  dest='c2model', action="store_true",
		help='Get crustal model for stations from Crust 2.0')
	parser.add_option('-t', '--c2thick',  dest='c2thick', action="store_true",
		help='Get crustal thickness for the US in regular spacing from Crust 2.0')
	parser.add_option('-M', '--compareMoho',  dest='compareMoho', action="store_true",
		help='Compare Moho depths from all models')
	parser.add_option('-C', '--compareCModel',  dest='compareCModel', action="store_true",
		help='Compare crustal models.')
	parser.add_option('-S', '--compareSediment',  dest='compareSediment', action="store_true",
		help='Compare sediment map.')
	parser.add_option('-g', '--savefig', action="store_true", dest='savefig',
		help='Save figure to file instead of showing.')
	opts, files = parser.parse_args(sys.argv[1:])
	return opts, files

def getmoho_c2_us():
	print('Get crustal thickness for the US from Crust 2.0')
	xyrange = [-127,-65,20,55]
	dxy = [.25,.25]
	ofile0='moho-crust2'
	ofile1='moho-crust2intp'
	c2thick(xyrange, dxy, ofile0, False)
	c2thick(xyrange, dxy, ofile1, True)
	print('Get Crust 2.0 crustal thickness for the US: ')
	print(ofile0)
	print(ofile1)

def getmoho_c2_sta(stadict, intpol=True):
	print('Get Moho depth for stations from Crust 2.0')
	if intpol:
		c2thick = point_c2thick_intpol
		ofile = 'sta-moho-crust2intpol'
	else:
		c2thick = point_c2thick
		ofile = 'sta-moho-crust2'
	mdict = {}
	for sta in stadict.keys():
		latlon = stadict[sta][:2]
		moho = c2thick(latlon)
		mdict[sta] = stadict[sta] + [moho, ]
	# convert crustal thickness to moho depth:
	for sta in mdict.keys():
		mdict[sta][3] -= mdict[sta][2]
	saveStation(mdict, ofile)

def getsedi_c2(stadict, cfile, ofile):
	print('Get sediment depth for stations from Crust 2.0')
	cmodel = readPickle(cfile)
	sdict = {}
	for sta in stadict.keys():
		sedi = cmodel[sta][0][2]
		sdict[sta] = stadict[sta] + [sedi, ]
	saveStation(sdict, ofile)

def getmodel_c2_sta(stadict, intpol=True):
	print('Get crustal model for stations using Crust 2.0')
	if intpol:
		c2model = point_c2model_intpol
		ofile = 'sta-cmodel-crust2intpol.pkl'
	else:
		c2model = point_c2model
		ofile = 'sta-cmodel-crust2.pkl'
	mdict = {}
	for sta in stadict.keys():
		latlon = stadict[sta][:2]
		mdict[sta] = c2model(latlon)
	writePickle(mdict, ofile)


def getmoho_na04(stadict, model='NA04'):
	ofile = 'sta-moho-' + model.lower()
	offset = 0.1
	mdict = {}
	for sta in stadict.keys():
		latlon = stadict[sta][:2]
		moho = point_moho(latlon, model, offset)
		mdict[sta] = stadict[sta] + [moho, ]
	saveStation(mdict, ofile)

def getmoho_lowry(stadict, mfile='MapHK.xyheke', ofile='sta-moho-lowry'):
	""" Moho from Tony Lowry for stations """
	knbrs = 5
	maxdist = 0.5
	vals = loadtxt(mfile)
	mohoxyz = vals[:,:3]
	mohoxy = vals[:,:2]
	mohoz = mohoxyz[:,2]
	mdict, xstas = find_moho(mohoxyz, stadict, knbrs, maxdist)
	# convert crustal thickness to moho depth:
	for sta in mdict.keys():
		mdict[sta][3] -= mdict[sta][2]
	print mfile,mdict
	saveStation(mdict, ofile) 

def plotmoho_lowry(stadict, mdict, mohoxy):
	astas = stadict.keys()
	ystas = mdict.keys()
	xstas = []
	for sta in astas:
		if sta not in ystas:
			xstas.append(sta)
	xvals = array([ stadict[sta][:2] for sta in xstas])
	yvals = array([ stadict[sta][:2] for sta in ystas])
	figure(figsize=(11,6))
	subplots_adjust(left=.07, right=.97)
	plot(mohoxy[:,0], mohoxy[:,1], 'g.', alpha=.3, label='Data')
	plot(xvals[:,1], xvals[:,0], 'r^', label='Stations not found')
	plot(yvals[:,1], yvals[:,0], 'b^', label='Stations found')
	axis([-127, -65, 23, 51])
	axis('equal')
	legend()
	xlabel('Longitude')
	ylabel('Latitude')
	show()


def getmoho_combo(stadict, modlist='na04-lowy', filehead='sta-moho-'):
	""" 
	Get Moho depth combined by models. 
	Modlist is a list of filenames separated by "-".
	"""
	mods = modlist.split('-')
	ofile = filehead + modlist
	adicts = [ readStation(filehead+mod)  for mod in mods ]
	mdict = {}
	for sta in stadict.keys():
		for adict in adicts:
			if sta in adict:
				mdict[sta] = adict[sta]
	saveStation(mdict, ofile)


def plotmoho_compare_moho(amodels, acolors, filehead='sta-moho-'):
	print('Plot Moho depth comparison for models: ',amodels)
	amohos = []
	for mod in amodels:
		modfile = filehead + mod
		mohos = loadtxt(modfile, usecols=(4,))
		amohos.append(mohos)
	# sort moho depth of the first model
	inds = argsort(amohos[0])
	figure(figsize=(20,6))
	rcParams['legend.fontsize'] = 11
	subplots_adjust(left=.05, right=.98)
	nmod = len(amodels)
	for i in range(nmod):
		mod = amodels[i]
		mohos = amohos[i]
		smohos = [ mohos[j]  for j in inds ]
		plot(smohos, color=acolors[i], marker='.', alpha=.4, ms=16, label=mod)
	xlabel('Station Number')
	ylabel('Moho Depth [km]')
	legend(loc=4)
	if opts.savefig:
		savefig('sta-moho-comparison-line.png', format='png')

	figure()
	bins = linspace(10, 60, 10)
	for i in range(nmod):
		mod = amodels[i]
		mohos = amohos[i]
		hist(mohos, bins, histtype='step', ec=acolors[i], fc='k', label=mod)
	xlabel('Moho Depth [km]')
	legend()
	if opts.savefig:
		savefig('sta-moho-comparison-hist.png', format='png')
	else:
		show()


def plotmoho_compare_cmodel(cfile0, cfile1, imodnm):
	print('Plot crustal models comparison')
	imodel = refModel(imodnm)
	cmodel0 = readPickle(cfile0)
	cmodel1 = readPickle(cfile1)	
	cmods = cmodel0, cmodel1
	mmodel0 = meanModel(cmodel0)
	mmodel1 = meanModel(cmodel1)
	figure(figsize=(10,16))
	subplots_adjust(left=.07, right=.97, bottom=.05, top=0.96, hspace=.08, wspace=.03)
	rcParams['legend.fontsize'] = 11
	astas = cmodel0.keys()#[:10]
	for sta in astas:
		col = rand(3)
		col = 'g'
		cols = [col, col]
		cols = ['y', 'g']
		subplot(211)
		plotcmodel(cmodel0[sta], cols, .5)
		subplot(212)
		plotcmodel(cmodel1[sta], cols, .5)
	cols = ['b', 'r']
	subplot(211)
	plotcmodel(imodel, cols, 3, '-', label=imodnm.upper())
	plotcmodel(mmodel0, cols, 3, '--', label='Mean crust2')
	xlim(-5,50)
	title(cfile0)
	ylabel('Velocity [km/s]')
	legend(loc=2)
	subplot(212)
	title(cfile1)
	plotcmodel(imodel, cols, 3, '-', label=imodnm.upper())
	plotcmodel(mmodel1, cols, 3, '--', label='Mean crust2intopl')
	xlim(-5,50)
	xlabel('Depth [km]')
	ylabel('Velocity [km/s]')
	legend(loc=2)
	if opts.savefig:
		savefig('sta-cmodel-comparison.png', format='png')
	else:
		show()

def plotmoho_compare_sediment():
	astas = sorted(stadict.keys())
	latlon = array([ stadict[sta][:2]  for sta in astas ])
	lat = latlon[:,0]
	lon = latlon[:,1]
	sedi0 = array([ sdict0[sta][3]  for sta in astas ])
	sedi1 = array([ sdict1[sta][3]  for sta in astas ])
	moho0 = array([ mdict0[sta][3]  for sta in astas ])
	moho1 = array([ mdict1[sta][3]  for sta in astas ])

	mohos = moho0, moho1
	sedis = sedi0, sedi1
	cfiles = cfile0, cfile1

	figure(figsize=(16,12))
	subplots_adjust(left=.03, right=.97, bottom=.03, top=0.96, hspace=.05, wspace=.05)
	sz = 7 
	for i in range(2):
		moho = mohos[i]
		sedi = sedis[i]
		cfile = cfiles[i]
		#
		subplot(2,2,i+1)
		title(cfile)
		plotphysio(False, True)
		plotcoast(True, True, True)
		axis([-126, -66, 25, 50])
		scatter(lon, lat, c=moho, marker='o', cmap=cmap, alpha=.5, s=sz**2)
		cbar = colorbar(orientation='h', pad=.07, aspect=30)
		cbar.set_label('Moho Depth [km]')
		#
		subplot(2,2,i+3)
		plotphysio(False, True)
		plotcoast(True, True, True)
		axis([-126, -66, 25, 50])
		scatter(lon, lat, c=sedi, marker='o', cmap=cmap, alpha=.5, s=sz**2)
		cbar = colorbar(orientation='h', pad=.07, aspect=30)
		cbar.set_label('Sediment Thickness [km]')
	if opts.savefig:
		savefig('sta-sedimoho.png', format='png')
	else:
		show()



if __name__ == '__main__':

	opts, files = getParams()

	# moho of regular spaced points
	if opts.c2thick:
		getmoho_c2_us()

	# moho for stations
	stafile = opts.stafile
	stadict = readStation(stafile)

	if opts.model is not None:
		model = opts.model.lower()
		print('Get Moho depth for stations using model: ' + model)
		if model == 'crust2':
			getmoho_c2_sta(stadict, False)
		if model == 'crust2intpol':
			getmoho_c2_sta(stadict, True)
		elif model == 'na04' or model == 'na07':
			getmoho_na04(stadict, model)
		elif model == 'lowry':
			mfile = 'moho-lowry'
			ofile='sta-moho-lowry'
			if not os.path.isfile(ofile):
				getmoho_lowry(stadict, mfile, ofile)
			mdict = readStation(ofile)
			vals = loadtxt(mfile)
			mohoxy = vals[:,:2]
			plotmoho_lowry(stadict, mdict, mohoxy)
		elif model == 'na04-lowry' or model == 'na07-lowry':
			getmoho_combo(stadict, model)

	# crustal model from crust 2.0 for stations:
	intpol = True
	if opts.c2model:
		getmodel_c2_sta(stadict, True)
		getmodel_c2_sta(stadict, False)

	# compare Mohos
	filehead='sta-moho-'
	amodels = 'crust2', 'crust2intpol', 'na04', 'na07', 'na04-lowry'
	acolors = 'bcgyr'
	if opts.compareMoho:
		plotmoho_compare_moho(amodels, acolors, filehead)

	# compare crust models
	cfile0 = 'sta-cmodel-crust2.pkl'
	cfile1 = 'sta-cmodel-crust2intpol.pkl'
	imodnm = 'iasp91'
	if opts.compareCModel:
		plotmoho_compare_cmodel(cfile0, cfile1, imodnm)

	# plot sediment thickness and moho in map
	sfile0 = 'sta-sedi-crust2'
	sfile1 = 'sta-sedi-crust2intpol'
	mfile0 = 'sta-moho-crust2'
	mfile1 = 'sta-moho-crust2intpol'


	ckey = 'RdBu_r'
	ckey = 'jet_r'
	cdict = cm.datad[ckey]
	cmap = matplotlib.colors.LinearSegmentedColormap(ckey, cdict)

	if opts.compareSediment:
		if not os.path.isfile(sfile0):
			getsedi_c2(stadict, cfile0, sfile0)
		if not os.path.isfile(sfile1):
			getsedi_c2(stadict, cfile1, sfile1)
		sdict0 = readStation(sfile0)
		sdict1 = readStation(sfile1)
		mdict0 = readStation(mfile0)
		mdict1 = readStation(mfile1)
		plotmoho_compare_sediment()

	
	sys.exit()

	# plot moho difference
	filehead = 'sta-moho-'
	amodels = 'na04', 'na07'
	amodels = 'na04-lowry', 'na07-lowry'
	acolors = 'bgrcm'
	mohos = array([ loadtxt(filehead+mod, usecols=(4,)) for mod in amodels ])
	for i in range(1, len(amodels)):
		plot(mohos[i]-mohos[0], '.')

	show()

