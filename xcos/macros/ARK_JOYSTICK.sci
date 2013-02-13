function [x,y,typ]=ARK_JOYSTICK(job,arg1,arg2)
//
// joystick.sci
//
// USAGE:
//
// output:
//  vector of axis values
//
// input:
//  user connected joystick
//
// Options: 
//
//  port: the port of the joystick
//
// AUTHOR:
//
// Copyright (C) James Goppert 2012 <jgoppert@users.sourceforge.net>
//
// joystick.sci is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// joystick.sci is distributed in the hope that it will be useful, but
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
			labels=['port number'];
			[ok,portNumber,exprs]=..
				getvalue('Set Joystick Parameters',labels,..
				list('vec',1),exprs);
			if ~ok then break,end
			model.out=[10];
			[model,graphics,ok]=check_io(model,graphics,[],model.out,[],[])
			if ok then
				model.ipar=[portNumber];
				graphics.exprs=exprs;
				x.graphics=graphics;
				x.model=model;
				break
			end
		end
	case 'define' then
		// set model properties
		model=scicos_model()
		model.sim=list('block_joystick',4)
		model.out=[10]
		model.blocktype='c'
		model.dep_ut=[%f %t]

		// jsbsim parameters
		portNumber=0;
		model.ipar=[portNumber];
		
		// initialize strings for gui
		exprs=[strcat(sci2exp(portNumber))];

		// setup icon
        gr_i='xstringb(orig(1),orig(2),''ARK_JOYSTICK'',sz(1),sz(2),''fill'')'
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
