function [x,y,typ]=waypointGuidance(job,arg1,arg2)
//
// waypointGuidance.sci
//
// USAGE: Calculate command errors for waypoint guidance.
//
// input 1: (destination)
//  [1] Lat
//  [2] Lon
//  [3] Altitude
//  [4] Velocity
//  
// input 2: (state x) 
//  [1]  Vt
//  [2]  Alpha
//  [3]  Theta
//  [4]  Q
//  [5]  Alt
//  [6]  Beta
//  [7]  Phi
//  [8]  P
//  [9]  R
//  [10] Psi
//  [11] Longitude
//  [12] Latitude,
//  [13] Rpm(if prop)
//   // not allowed currently [14] PropPitch (if prop)
//
// output 1: command error
//  [1] eH (altitude error)
//  [2] eV (true velocity error)
//  [3] eR (yaw rate error)
//  [4] ePsi (heading error)
//  [5] ePhi (roll error)
//
// AUTHOR:
//
// Copyright (C) Alan Kimi, James Goppert 2011
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
		model.sim=list('sci_waypointGuidance',4)
		model.evtin=[];
		model.in=[4;13];
		model.out=[5];
		model.blocktype='c';
		model.dep_ut=[%t %f];

        exprs='waypointGuidance';

		// setup icon
	  	gr_i=['xstringb(orig(1),orig(2),''waypointGuidance'',sz(1),sz(2),''fill'');']
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
