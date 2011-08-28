function [x,y,typ]=quadForceMoments(job,arg1,arg2)
//
// quadForceMoments.sci
//
// USAGE:
//
// input 1: (imu data)
//  [1] wx (rad/s) 		(body)
//  [2] wy (rad/s)		(body)
//  [3] wz (rad/s)	    (body)
//  [4] fx (unit distance/s^2) (body)
//  [5] fy (unit distance/s^2) (body)
//  [6] fz (unit distance/s^2) (body)
//	default unit distance is meters
//
// input 2: (gravity model)
//  [1]  g       (unit distance/s^2) (body)
//
// input 3: (state) 
//
//    mode 0  mode 1  mode 2
//  	full   att.  vel/pos
// 		[1]  	[1] 	[ ] 	 a      (quaternion)
// 		[2]   	[2] 	[ ] 	 b 		(quaternion)
// 		[3]   	[3] 	[ ] 	 c		(quaternion)
// 		[4]   	[4] 	[ ] 	 d      (quaternion)
// 		[5]   	[ ] 	[1] 	 Vn 	(unit distance/s)
// 		[6]   	[ ] 	[2] 	 Ve 	(unit distance/s)
// 		[7]   	[ ] 	[3] 	 Vd 	(unit distance/s)
// 		[8]   	[ ] 	[4] 	 Lat 	(rad)
// 		[9]   	[ ] 	[5] 	 Lon 	(rad)
// 		[10]   	[ ] 	[6] 	 alt 	(unit distance)
//
// output 1: (state derivative)
//
// 	  mode 0  mode 1  mode 2
//  	full   att.  vel/pos
// 		[1]  	[1] 	[ ] 	 d/dt a    	(quaternion)
// 		[2]   	[2] 	[ ] 	 d/dt b 	(quaternion)
// 		[3]   	[3] 	[ ] 	 d/dt c		(quaternion)
// 		[4]   	[4] 	[ ] 	 d/dt d     (quaternion)
// 		[5]   	[ ] 	[1] 	 d/dt Vn 	(unit distance/s)
// 		[6]   	[ ] 	[2] 	 d/dt Ve 	(unit distance/s)
// 		[7]   	[ ] 	[3] 	 d/dt Vd 	(unit distance/s)
// 		[8]   	[ ] 	[4] 	 d/dt Lat 	(rad)
// 		[9]   	[ ] 	[5] 	 d/dt Lon 	(rad)
// 		[10]   	[ ] 	[6] 	 d/dt alt 	(unit distance)
//
//	default unit distance is meters
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
		graphics=arg1.graphics;exprs=graphics.exprs
		model=arg1.model;
		while %t do
			labels=[..
				'Omega (rad/s)';..
				'Re (unit distance)';..
				'state mode: full(0), attitude(1), velocity position(2)'];
			[ok,Omega,Re,stateMode,exprs]=..
				getvalue('Set Planet Parameters',labels,..
				list('vec',1,'vec',1,'vec',1),exprs);
			if ~ok then break,end
				graphics.exprs=exprs;

			// set sizes based on mode
			if stateMode==0 then
				nOut=10;
				nIn=[6;1;10]
			elseif stateMode==1 then
				nOut=4;
				nIn=[3;1;4]
			elseif stateMode==2 then
				nOut=6;
				nIn=[3;1;6]
			else
				disp('invalid mode in insDynamcis block');
				error('invalid mode in quadForceMoments block');
			end

			model.out=[nOut];
			model.in=[nIn];
			[model,graphics,ok]=check_io(model,graphics,nIn,nOut,[],[])
			if ok then
				model.rpar=[Omega,Re];
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
		model.sim=list('sci_quadForceMoments',4);

		nOut=10;
		nIn=[6;1;10]

		model.in=nIn;
		model.out=nOut;
		model.blocktype='c';
		model.dep_ut=[%t %f];

		// gpsIns parameters
		Omega = 7.292115e-5;
		Re=6378137;
		stateMode=0; // full state
		
		model.rpar=[Omega,Re];
		model.ipar=stateMode;
		
		// initialize strings for gui
		exprs=[..
			strcat(sci2exp(Omega)),..
			strcat(sci2exp(Re)),..
			strcat(sci2exp(stateMode))];

		// setup icon
	  	gr_i=['xstringb(orig(1),orig(2),[''quad Force'';''Moments''],sz(1),sz(2),''fill'');']
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
