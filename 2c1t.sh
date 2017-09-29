#!/bin/bash

###############################################################################################################
###############################################################################################################
#
#   Generador de Modelo en Fdelmodc
#   Jahiro D. Calvet
#
###############################################################################################################
###############################################################################################################


##############################################    Definicoes padrao    #######################################################

#grid=5
#grid=10
sizex=1000
sizez=500
dx=0.6601


##############################################    Generador do modelo  #######################################################


makemod file_base=model.su  cp0=800 ro0=90 cs0=471 sizex=$sizex sizez=$sizez dx=$dx dz=$dx  orig=0,0 x=0,$sizex z=0,0 \
		intt=def poly=0 cp=1000  ro=500  cs=588	  x=0,$sizex 		z=50,50 \
		intt=def poly=0 cp=1200  ro=1200 cs=706  x=0,$sizex 		z=100,100 \
		intt=def poly=0 cp=1400  ro=2000 cs=824  x=0,$sizex 		z=150,150 \
		intt=def poly=0 cp=1600  ro=3000 cs=941  x=0,$sizex 		z=300,300 \
		intt=def poly=2 cp=2000  ro=4500 cs=1176 \
		verbose=1

# display the models (velocity and density)

filecp=model_cp.su
filecs=model_cs.su
filero=model_ro.su

#suximage < $filecp wbox=800 hbox=400 title="Vp model"  xbox=0     ybox=0 legend=10 &
#suximage < $filecs wbox=800 hbox=400 title="Vs model"  xbox=800   ybox=0  legend=10 &
#suximage < $filero wbox=800 hbox=400 title="Rho model" xbox=0     ybox=450 legend=10 &


############################################  Generador da onda (wavelet)  #####################################################

makewave file_out=wavelet.su dt=0.0002 nt=8192 fp=50 shift=1 w=g1 verbose=1

############################################     Parametros  Fdelmodc      #####################################################

xrcv1=0
xrcv2=$sizex
dxrcv=10

xsource=$(echo "scale=0 ; $sizex / 2" | bc -l)

#xsrc=500


zrcv1=0
zrcv2=0

time fdelmodc \
	file_cp=$filecp file_den=$filero file_cs=$filecs \
	ischeme=1 \
	file_src=wavelet.su verbose=4 \
	file_rcv=rec.su \
	file_snap=snap.su \
	xrcv1=$xrcv1 \
	xrcv2=$xrcv2 \
	dxrcv=$dxrcv \
	zrcv1=$zrcv1 \
	zrcv2=$zrcv2 \
	sinkdepth=0 \
	rec_type_p=1 \
	rec_type_vx=1 \
	rec_type_vz=1 \
	rec_int_p=3 \
	rec_int_vx=3 \
	rec_int_vz=3 \
	dtrcv=0.0015 \
    src_type=1 \
	xsrc=$xsource \
	zsrc=10 \
	nsrc=20 \
	plane_wave=0 \
	nshot=1 \
	tsnap1=0.1 tsnap2=3.0 dtsnap=0.1 \
	sna_type_p=1 sna_type_p=1 \
	src_orient=2 \
	top=4 bottom=4 left=4 right=4 ntaper=400 tapfact=0.3 \
	tmod=0.5 \
	fmax=302.984406 \
	#nzmax=300 nxmax=300


#echo $xsource


# to show a movie of the snapshots
suxmovie < snap_svz.su perc=99 loop=1 sleep=4


##############################################    graficar as camadas  #######################################################

supsimage < $filecp \
	wbox=4 hbox=4 titlesize=-1 labelsize=10 verbose=1 \
	d2=1 f2=0 n1tic=10 n2tic=10 x2beg=0 x2end=$sizex x1beg=0 x1end=$sizez wrgb=1.0,1.0,0 grgb=1.0,0.0,0 brgb=0,0.0,1.0 bps=24 perc=96 \
	label1="Profundidade [m]" label2="Deslocamento lateral [m]" > modelo_cp.eps

supsimage < SrcRecPositions.su \
	wbox=4 hbox=4 titlesize=-1 labelsize=15 verbose=1 perc=96 bps=24 \
	d2=1 f2=-256.5 n1tic=10 n2tic=10 x2beg=0 x2end=$sizex x1beg=0 x1end=$sizez wclip=-1 bclip=1   \
	gabel1="Profundidade [m]" label2="Deslocamento lateral [m]" > SrcRecPositions.eps

suop2 $filecp  SrcRecPositions.su w1=1 w2=1000 op=sum | \
	supsimage \
	wbox=4 hbox=4 titlesize=-1 labelsize=10 verbose=1 \
	d2=1 f2=-256.5  n1tic=10 n2tic=10 x2beg=0 x2end=$sizex x1beg=0 x1end=$sizez wrgb=0.0,0.1,0 grgb=1.0,1.0,0 brgb=1.0,0.0,0  bps=24 perc=96 \
	label1="Profundidade [m]" label2="Deslocamento lateral [m]" > model_y_src.eps







##############################################  registro de los sismogramas #######################################################


supsimage < rec_rvz.su \
	wbox=3 hbox=4 titlesize=-1 labelsize=10 clip=1e-10 verbose=1 \
	label1="Tempo [s]" label2="Deslocamento lateral [m]" > rec_rvz.eps

supsimage < rec_rvx.su \
	wbox=3 hbox=4 titlesize=-1 labelsize=10 clip=1e-10 verbose=1 \
	label1="Tempo [s]" label2="Deslocamento lateral [m]" > rec_rvx.eps


supsimage < rec_rp.su \
	wbox=3 hbox=4 titlesize=-1 labelsize=10 clip=1e-11 verbose=1 \
	label1="Tempo [s]" label2="Deslocamento lateral [m]" > rec_rp.eps


fconv file_in1=src_nwav.su auto=1 shift=1 mode=cor1 | \
	sugain qbal=1 | \
	supswigp x1beg=-1 x1end=1 d2num=1 hbox=4 wbox=6 \
	labelsize=10 label2='Numero de fontes' label1='Tempo (s)' \
	titlesize=-1 fill=0 > src_nwav_autoCorr_Norm.eps





##############################################    graficos para as fontes  #######################################################

a=$(echo "($tmod*1000+0.5)/1" | bc )
b=$(echo "($a+0.1)" | bc )


psgraph < srcTimeLengthN\=$(($a+1)).bin n1=$(($a+1)) \
    labelsize=12 d1=0.001 style=normal linecolor=blue \
    label1="Tempo do inicio (s)" label2="Tempo de duracao das fontes (s)" \
    d1num=0.2 d2num=0.2 wbox=8 hbox=4 x1end=0.6 > srcTimeLength.eps

supswigp < src_nwav.su \
	labelsize=10 label1='Tempo (s)' label2='O numero das fontes' x1end=6 \
	d2=1 d2num=5 hbox=4 wbox=6 fill=0 \
	titlesize=-1 > src_nwav.eps

suwind < src_nwav.su key=tracl min=11 max=11 | \
	supsgraph hbox=2 wbox=4 style=normal \
	labelsize=10 label2='Amplitude' label1='Tempo (s)' \
	titlesize=-1 d1num=1.0 > src11_wiggle.eps

suwind < src_nwav.su key=tracl min=11 max=11 | \
	supsgraph hbox=2 wbox=4 style=normal \
	labelsize=10 label2='Amplitude' label1='Tempo (s)' \
	titlesize=-1 x1end=0.05 > src11_wiggle_zbeg.eps

suwind < src_nwav.su key=tracl min=11 max=11 | \
	supsgraph hbox=2 wbox=4 style=normal \
	labelsize=10 label2='Amplitude' label1='Tempo (s)' \
	titlesize=-1 x1beg=0.95 x1end=1.0 > src11_wiggle_zend.eps

suwind < src_nwav.su key=tracl min=11 max=11 | \
	sufft | suamp| supsgraph hbox=2 wbox=4 style=normal \
	labelsize=10 label2='Amplitude' label1='frequency (Hz)' \
	titlesize=-1 x1end=100 d1num=10 > src11_ampl.eps




############################################  verificacao analitica dos dados ####################################################



#sugain < SrcRecPositions.su scale=1000 > nep.su

#susum nep.su  "$modelo"_cp.su > sum.su

#supsimage < sum.su bclip=1000 wclip=0 \
#    wbox=4 hbox=4 titlesize=-1 labelsize=10 verbose=1 \
#    label1="depth [m]" label2="lateral position [m]" blockinterp=1 \
#	> 2capas.eps


#exit;



echo $z1, $z2, $z3, $z4, $z5, $e1, $e2
