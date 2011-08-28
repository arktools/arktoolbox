function [x,y,typ]=gpsIns(job,arg1,arg2)
//
// gpsIns.sci
//
// USAGE:
//
// output 1: (state x) 
//  [1]  Lat 	(rad)
//  [2]  Lon 	(rad)
//  [3]  Alt 	(m)
//  [4]  roll 	(rad)
//  [5]  pitch 	(rad)
//  [6]  yaw 	(rad)
//  [7]  Vn 	(m/s)
//  [8]  Ve 	(m/s)
//  [9]  Vd 	(m/s)
//
// input 1: (input u1)
//  [1] fbx (m/s^2) (inertial)
//  [2] fby (m/s^2) (inertial)
//  [3] fbz (m/s^2) (inertial)
//  [4] wbx (m/s^2) (inertial)
//  [5] wby (m/s^2) (inertial)
//  [6] wbz (m/s^2) (inertial)
//
// input 2: (input u2)
//  [1]  Lat 	(rad)
//  [2]  Lon 	(rad)
//  [3]  Alt 	(m)
//  [4]  Phi 	(rad)
//  [5]  Theta 	(rad)
//  [6]  Psi 	(rad)
//  [7]  Vn 	(m/s)
//  [8]  Ve 	(m/s)
//  [9]  Vd 	(m/s)
//
// AUTHOR:
//
// Copyright (C) Brandon Wampler 2010 <bwampler@users.sourceforge.net>
//
// gpsIns.sci is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// gpsIns.sci is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  If not, see <http://www.gnu.org/licenses/>.
//
mode(-1);
x=[];y=[];typ=[];

select job
	case 'plot' then
	 	standard_draw(arg1)
	case 'getinputs' then
	 	[x,y,typ]=standard_inputs(arg1)
	case 'getoutputs' then
	 	[x,y,typ]=standard_outputs(arg1)
	case 'getorigin' then
	 	[x,y]=standard_origin(arg1)
	case 'set' then
		x=arg1;
		graphics=arg1.graphics;exprs=graphics.exprs
		model=arg1.model;
		while %t do
			labels=[..
				'Position sigma (m)';..
				'Alt sigma (m)';..
				'Velocity sigma (m)';..
				'Accel. sigma (m/s^2)';..
				'Gyro sigma (rad/s)'];
			[ok,SigmaPos,SigmaAlt,SigmaVel,SigmaAccel,SigmaGyro,exprs]=..
				getvalue('Set GpsIns Parameters',labels,..
				list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs);
			if ~ok then break,end
			model.out=[9];
			[model,graphics,ok]=check_io(model,graphics,model.in,model.out,model.evtin,[])
			if ok then
				model.rpar=[];
				graphics.exprs=exprs;
				x.graphics=graphics;
				x.model=model;
				break
			end
		end
	case 'define' then
		// set model properties
		model=scicos_model()
		model.sim=list('sci_gpsIns',4)
		model.evtin=[1];
		model.in=[6;9]
		model.out=[9]
		model.blocktype='c'
		model.dep_ut=[%t %f]

		// gpsIns parameters
		SigmaPos=10;
		SigmaAlt=5;
		SigmaVel=1;
		SigmaAccel=.001;
		SigmaGyro=.002;
		model.rpar=[SigmaPos,SigmaAlt,SigmaVel,SigmaAccel,SigmaGyro];
		
		// initialize strings for gui
		exprs=[
			strcat(sci2exp(SigmaPos)),..
			strcat(sci2exp(SigmaAlt)),..
			strcat(sci2exp(SigmaVel)),..
			strcat(sci2exp(SigmaAccel)),..
			strcat(sci2exp(SigmaGyro))];

		// setup icon
	  	gr_i=['xstringb(orig(1),orig(2),''GpsIns'',sz(1),sz(2),''fill'');']
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
