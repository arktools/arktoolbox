function [x,y,typ]=magMeasModel(job,arg1,arg2)
//
// magMeasModel.sci
//
// USAGE:
//
// output 1: 
//
// 	mode 0 (full state)
//
//  	H_mag (3x10), measurement matrix
//
// 	mode 1 (att (quaternion) state)
//
//  	H_mag (3x4), measurement matrix
//
// output 2: 
//
//  R_mag_n (3x3), measurement covariance
//
// 	Note: This is in the navigation frame, use
//  	C_nb to perform a similarity transformation
//
// input 1: (local magnetic field direction)
//  [1] dip, inclination (rad)
//  [2] dec, declination rad)
//
// input 2: (std. deviation for local magnetic field direction)
//  [1] std deviaton of dip, inclination (rad)
//  [2] std deviaton of dec, declination (rad)
//
// input 3: (quaternion from body to navigation frame q_nb)
//  [1]  a      quaternion
//  [2]  b 		quaternion
//  [3]  c		quaternion
//  [4]  d      quaternion
//
// AUTHOR:
//
// Copyright (C) Alan Kim, James Goppert  2011
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

// globals
in=[2;2;4];

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
			labels=['state mode: full(0), attitude(1)'];
			[ok,stateMode,exprs]=getvalue('Set State Mode',labels,list('vec',1),exprs);

			if ~ok then break,end
				graphics.exprs=exprs;

			// set sizes based on mode
			if stateMode==0 then
				out=[3;3]
				out2=[10;3]
			elseif stateMode==1 then
				out=[3;3]
				out2=[4;3]
			else
				disp('invalid mode in insDynamcis block')
				error('invalid mode in insDynamics block')
			end
			model.out=out;
			model.out2=out2;
			model.in=in;
			[model,graphics,ok]=check_io(model,graphics,in,out,[],[])
			if ok then
				model.ipar=stateMode;
				graphics.exprs=exprs;
				x.graphics=graphics;
				x.model=model;
				break
			end
		end
	case 'define' then
		// set model properties
		model=scicos_model();
		model.sim=list('sci_magMeasModel',4);
		model.in=in;
		stateMode=0;	
		model.ipar=stateMode;
		model.out=[3;3];
		model.out2=[10;3];
		model.blocktype='c';
		model.dep_ut=[%t %f];
		exprs=[strcat(sci2exp(stateMode))];

		// setup icon
	  	gr_i=['xstringb(orig(1),orig(2),''magMeasModel'',sz(1),sz(2),''fill'');']
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
