#!/bin/bash


##############################################    Definicoes padrao    #######################################################

grid=5
grid=10
sizex=800
sizez=400
dx=0.6400


x1=$(echo "scale=0 ; $sizex / 2.22 " | bc -l)
x2=$(echo "scale=0 ; $sizex / 1.90 " | bc -l)


z1=$(echo "scale=0 ; $sizez / 9.84" | bc -l)
z2=$(echo "scale=0 ; $sizez / 6 " | bc -l)
z3=$(echo "scale=0 ; $sizez / 4.41 " | bc -l)
z4=$(echo "scale=0 ; $sizez / 3.43 " | bc -l)
z5=$(echo "scale=0 ; $sizez / 2.22 " | bc -l)

e1=$(echo "scale=0 ; $sizex / 8.33 " | bc -l)
e2=$(echo "scale=0 ; $e1 * 1.25 " | bc -l)



######################################### Generador do modelo ######################################


makemod file_base=model.su  cp0=800 ro0=600 cs0=462 sizex=$sizex sizez=$sizez dx=$dx dz=$dx  orig=0,0\
         intt=def poly=0 cp=900 ro=1000 cs=520 x=0,$sizex z=$z1,$z1 gradcp=0.0 grad=0 \
         intt=def poly=2 cp=1000 ro=1200 cs=588 x=0,$sizex z=$z2,$z2 gradcp=0.0 grad=0 \
         intt=def poly=0 cp=1400  ro=1400 cs=824  x=0,$sizex z=$z3,$z3 gradcp=0.0 grad=0\
         intt=def poly=0 cp=1600  ro=2000 cs=941  x=0,$sizex z=$z4,$z4 gradcp=0.0 grad=0\
         intt=elipse var=12,30 cp=800 ro=1.29 cs=4710 x=$x1 z=$z5  gradcp=0.0 grad=0 \
         intt=elipse var=12,30 cp=800 ro=1.29 cs=4710 x=$x2 z=$z5  gradcp=0.0 grad=0 \
         intt=def poly=0 cp=1600  ro=2000 cs=941  x=0,$sizex z=$z5,$z5 gradcp=0.0 grad=0\
         verbose=4


filecp=model_cp.su
filecs=model_cs.su
filero=model_ro.su

suximage < $filecp wbox=800 hbox=400 title="Vp model"  xbox=0     ybox=0 legend=10 &
suximage < $filecs wbox=800 hbox=400 title="Vs model"  xbox=800   ybox=0  legend=10 &
suximage < $filero wbox=800 hbox=400 title="Rho model" xbox=0     ybox=450 legend=10 &


################################### Generador da onda (wavelet)  ###################################

makewave file_out=wavelet.su dt=0.0002 nt=8192 fp=100 shift=1 w=g1 verbose=1

#####################################  Parametros  Fdelmodc     ####################################

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
    rec_int_vx=3 \
    rec_int_vz=3 \
	dtrcv=0.004 \
    src_type=1 src_orient=1 \
	xsrc=$xsource \
	zsrc=0 \
	nshot=1 \
	tsnap1=0.1 tsnap2=3.0 dtsnap=0.1 \
	sna_type_p=1 sna_type_vz=1 \
	src_orient=2 \
	top=4 bottom=4 left=4 right=4 ntaper=400 tapfact=0.3 \
	tmod=0.5 \
	fmax=250 \
#	nzmax=300 nxmax=300


#echo $xsource


# to show a movie of the snapshots
suxmovie < snap_svz.su perc=96 loop=1 sleep=4



supsimage < $filecp \
	wbox=4 hbox=4 titlesize=-1 labelsize=10 verbose=1 \
	d2=1 f2=0 wrgb=1.0,1.0,0 grgb=1.0,0.0,0 brgb=0,0.0,1.0 bps=24 perc=96 \
	label1="Profundidade [m]" label2="Deslocamento lateral [m]" > modelo_cp.eps

supsimage < SrcRecPositions.su \
	wbox=4 hbox=4 titlesize=-1 labelsize=10 verbose=1 perc=96\
	d2=1 f2=0 wclip=-1 bclip=1   \
	gabel1="Profundidade [m]" label2="Deslocamento lateral [m]" > SrcRecPositions.eps

suop2 $filecp  SrcRecPositions.su w1=1 w2=1000 op=sum | \
	supsimage  wclip=1000 bclip=1000 \
	wbox=4 hbox=4 titlesize=-1 labelsize=10 verbose=1 \
	d2=1 f2=1 wrgb=0.0,0.1,0 grgb=1.0,1.0,0 brgb=1.0,0.0,0  bps=24 perc=96 \
	label1="Profundidade [m]" label2="Deslocamento lateral [m]" > model_y_src.eps


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









#sugain < SrcRecPositions.su scale=1000 > nep.su

#susum nep.su  "$modelo"_cp.su > sum.su

#supsimage < sum.su bclip=1000 wclip=0 \
#    wbox=4 hbox=4 titlesize=-1 labelsize=10 verbose=1 \
#    label1="depth [m]" label2="lateral position [m]" blockinterp=1 \
#	> 2capas.eps


#exit;



echo $z1, $z2, $z3, $z4, $z5, $e1, $e2
