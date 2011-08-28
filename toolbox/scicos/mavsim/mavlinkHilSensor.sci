function [x,y,typ]=mavlinkHilSensor(job,arg1,arg2)
//
// mavlinkHilSensor.sci
//
// USAGE:
//
// input: 
//   accel
//     [1] aX
//     [2] aY
//     [3] aZ
//   gyro
//     [4] gX
//     [5] gY
//     [6] gZ
//   mag
//     [7] mX
//     [8] mY
//     [9] mZ
//   gps
//     [10] cog (course over ground)
//     [11] sog (speed over ground)
//     [12] lat
//     [13] lon
//     [14] alt
//
// output: 
// 	   normalized servos [1]-[8]
// 	   [9 ] lat
// 	   [10] lon
//     [11] alt
//     [12] vN
//     [13] vE
//     [14] vD
//     [15] roll
//     [16] pitch
//     [17] yaw
//     [18] roll speed
//     [19] pitch speed
//     [20] yaw speed
//
// AUTHOR:
//
// Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
//
// mavlinkHil.sci is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// mavlinkHil.sci is distributed in the hope that it will be useful, but
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
			labels=['device';'baud rate'];
			[ok,device,baudRate,exprs]=..
				getvalue('Set mavlink HIL Parameters',labels,..
				list('str',-1,'vec',1),exprs);
			if ~ok then break,end
			[model,graphics,ok]=check_io(model,graphics,[14],[8],[1],[])
			if ok then
				model.ipar=[..
					length(evstr(device)),ascii(evstr(device)),0,..
					baudRate];
				graphics.exprs=exprs;
				x.graphics=graphics;
				x.model=model;
				break
			end
		end
	case 'define' then
		// set model properties
		model=scicos_model()
		model.sim=list('sci_mavlinkHilSensor',4)
		model.in=[14]
		model.out=[8]
		model.evtin=[1]
		model.blocktype='c'
		model.dep_ut=[%t %f]

		// jsbsim parameters
		device="""/dev/ttyUSB1""";
		baudRate=115200;
		model.ipar=[..
					length(evstr(device)),ascii(evstr(device)),0,..
					baudRate];

		// initialize strings for gui
		exprs=[strcat(device),strcat(sci2exp(baudRate))];

		// setup icon
	  	gr_i=['xstringb(orig(1),orig(2),''mavlink HIL Sensor'',sz(1),sz(2),''fill'');']
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
