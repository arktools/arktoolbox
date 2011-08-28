function [x,y,typ]=gpsMeasModel(job,arg1,arg2)
//
// gpsMeasModel.sci
//
// USAGE:
//
// input 1:
//   [1] h (altitude) (unit distance, set by real parameter R)
//   [2] L (latitude) (radians)
//
// input 2:
//   [1] velocity error std deviation (unit distance/second)
//   [2] position error std deviation (unit distance)
//   [2] altitude error std deviation (unit distance)
//
// output 1: 
//
//  mode (0)
//   H_gps (6x10)
//
//  mode (1)
//    attitude state not allowed, since H would be zero
//
//  mode (2)
//   H_gps (6x6)
//
// output 2:
//   R_gps (6x6)
//
// AUTHOR:
//
// Copyright (C) James Goppert  2011
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

// won't change
in=[2;3];

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
				'state mode: full(0), attitude(2), mode 1 not allowed';..
				'radius of earth'];
			[ok,stateMode,Re,exprs]=getvalue('Set State Mode',labels,list('vec',1,'vec',1),exprs);

			if ~ok then break,end
				graphics.exprs=exprs;

			// set sizes based on mode
			if stateMode==0 then
				out=[6;6]
				out2=[10;6]
			elseif stateMode==2 then
				out=[6;6]
				out2=[6;6]
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
		model.sim=list('sci_gpsMeasModel',4);
		model.in=in;

		stateMode=0;	
		Re=6378137;

		model.ipar=stateMode;
		model.rpar=Re;
		model.out=[6;6];
		model.out2=[10;6];
		model.blocktype='c';
		model.dep_ut=[%t %f];
		exprs=[strcat(sci2exp(stateMode)),strcat(sci2exp(Re))];

		// setup icon
	  	gr_i=['xstringb(orig(1),orig(2),''gpsMeasModel'',sz(1),sz(2),''fill'');']
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
