#!/bin/bash
if [ $# != 1 ]
then
	echo program for communicating with flightgearcomm
	echo this doesn't currently work for flightgear > 1.0
	echo usage: $0 aircraft
	exit
fi
aircraft=$1
gdb --args fgfs \
--disable-sound \
--native-fdm=socket,out,120,,5500,udp \
--native-ctrls=socket,out,119,,5501,udp \
--native-ctrls=socket,in,120,,5502,udp \
--aircraft=$aircraft \
--geometry=400x300 \
--vc=30 \
--altitude=1000 \
--heading=90 \
--roll=0 \
--pitch=0 \
--wind=0@0 \
--turbulence=0.0 \
--timeofday=noon \
--shading-flat \
--notrim \
--fog-disable \
--disable-specular-highlight \
--disable-skyblend \
--disable-random-objects \
--disable-panel \
--disable-horizon-effect \
--disable-clouds \
--disable-anti-alias-hud
