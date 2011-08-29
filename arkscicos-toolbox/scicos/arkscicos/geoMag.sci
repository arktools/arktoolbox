function [x,y,typ]=geoMag(job,arg1,arg2)
//
// geoMag.sci
//
// USAGE:
//
// output 1: (unit vector of magnetic field direction)
//  [1]  dip (rad)
//  [2]  dec (rad)
//  [3]  H0a (nT)
//
// input 1: (euler angles)
//  [1] lat 	(rad)
//  [2] lon 	(rad)
//  [3] alt 	(m)
//
// AUTHOR:
//
// Copyright (C) James Goppert Alan Kim 2011
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
				'Decimal Year';..
				'Number of Terms'];
			[ok,decYear,nTerms]=..
				getvalue('Set WMM Parameters',labels,..
				list('vec',1,'vec',1),exprs);
			if ~ok then break,end
				graphics.exprs=exprs;
			[model,graphics,ok]=check_io(model,graphics,[3],[3],[],[])
			if ok then
				model.rpar=decYear;
				model.ipar=nTerms;
				graphics.exprs=exprs;
				x.graphics=graphics;
				x.model=model;
				break
			end
		end
	case 'define' then
		// set model properties
		model=scicos_model()
		model.sim=list('sci_geoMag',4)
		model.in=[3];
		model.out=[3];
		model.blocktype='c';
		model.dep_ut=[%t %f];

		// geoMag parameters
		decYear = 2011.1;
		nTerms = 12;
		
		model.rpar=decYear;
		model.ipar=nTerms;
		
		// initialize strings for gui
		exprs=[
			strcat(sci2exp(decYear)),..
			strcat(sci2exp(nTerms))];
;

		// setup icon
	  	gr_i=['xstringb(orig(1),orig(2),''geoMag'',sz(1),sz(2),''fill'');']
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
