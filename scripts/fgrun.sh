#!/bin/bash
#--disable-textures \
if [ $# != 1 ]
then
	echo usage: $0 aircraft
	fgfs --show-aircraft
	exit
fi
aircraft=$1
fgfs \
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
--notrim \
#--shading-flat \
#--fog-disable \
#--disable-specular-highlight \
#--disable-skyblend \
#--disable-random-objects \
#--disable-panel \
#--disable-horizon-effect \
#--disable-clouds \
#--disable-anti-alias-hud
