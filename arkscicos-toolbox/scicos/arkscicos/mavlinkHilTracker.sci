function [x,y,typ]=mavlinkHilTracker(job,arg1,arg2)
//
// mavlinkHilTracker.sci
//
// USAGE:
//
// input: 
//   position
//    [1] lat (rad)
//    [2] lon (rad)
//    [3] alt (meters)
//   velocity
//    [4] vN (m/s)
//    [5] vE (m/s)
//    [6] vD (m/s)
//
// output: 
// 	   normalized servos [1]-[8]
//
// AUTHOR:
//
// Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
//
// This file is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This file is distributed in the hope that it will be useful, but
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
			[model,graphics,ok]=check_io(model,graphics,[6],[8],[1],[])
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
		model.sim=list('sci_mavlinkHilTracker',4)
		model.in=[6]
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
	  	gr_i=['xstringb(orig(1),orig(2),''mavlink HIL Tracker'',sz(1),sz(2),''fill'');']
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
