function [x,y,typ]=quat2EulerDcm(job,arg1,arg2)
//
// quat2EulerDcm.sci
//
// USAGE:
//
// output 1: Cnb (3x3)
//
// output 2: euler angles
//  [1] phi (rad) <roll>
//  [2] theta (rad) <pitch>
//  [3] psi (rad) <yaw>
//
// output 3: euler angle rates
//  [1] phiRate (rad/s) <roll rate>
//  [2] thetaRate (rad/s) <pitch rate>
//  [3] psiRate (rad/s) <yaw rate>
//
// input 1: (quaternion from nav to body frame)
//  [1] a : cos(angle/2)
//  [2] b : sin(angle/2) * vx 
//  [3] c : sin(angle/2) * vy
//  [4] d : sing(angle/2)* vz
//
// AUTHOR:
//
// Copyright (C) Alan Kim, James Goppert 2011
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
		model.sim=list('sci_quat2EulerDcm',4)
		model.evtin=[];
		model.in=[4;3];
		model.in2=[1;1];
		model.out=[3;3;3];
		model.out2=[3;1;1];
		model.blocktype='c';
		model.dep_ut=[%t %f];
		exprs = 'quat2EulerDcm';	

		// setup icon
	  	gr_i=['xstringb(orig(1),orig(2),''quat2EulerDcm'',sz(1),sz(2),''fill'');']
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
