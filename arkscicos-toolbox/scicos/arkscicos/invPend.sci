function [x,y,typ]=invPend(job,arg1,arg2)
//
// invPend.sci
// Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
//
// invPend.sci is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// invPend.sci is distributed in the hope that it will be useful, but
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
		M="M";m="m";l="l";ph="ph";
	  	model=scicos_model()
	  	model.sim=list('sci_invPend',4)
		model.in=[1;1;1]
	  	model.out=[1;1]
		model.rpar=[M;m;l;ph]
	  	model.blocktype='c'
	  	model.dep_ut=[%t %f]
	  	exprs='sci_invPend'
	  	gr_i=['xstringb(orig(1),orig(2),..
			[''Inverted Pendulum''],sz(1),sz(2),''fill'');']
	  	x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
