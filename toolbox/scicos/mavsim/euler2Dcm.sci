function [x,y,typ]=euler2Dcm(job,arg1,arg2)
//
// euler2Dcm.sci
//
// USAGE:
//
// input 1: euler angles
//  [1] phi (rad) <roll>
//  [2] theta (rad) <pitch>
//  [3] psi (rad) <yaw>
//
// output 1: Cnb (3x3)
//
// AUTHOR:
//
// Copyright (C) James Goppert 2011
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
	case 'define' then
		// set model properties
		model=scicos_model()
		model.sim=list('sci_euler2Dcm',4)
		model.evtin=[];
		model.in=[3];
		model.out=[3];
		model.out2=[3];
		model.blocktype='c';
		model.dep_ut=[%t %f];
		exprs = 'euler2Dcm';	

		// setup icon
	  	gr_i=['xstringb(orig(1),orig(2),''euler2Dcm'',sz(1),sz(2),''fill'');']
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
