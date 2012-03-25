function [x,y,typ]=sailboatForceMoments(job,arg1,arg2)
//
// sailboatForceMoments.sci
//
// USAGE:
//
// Input:
//  u1: winchPosition, rudderPosition
//  u2: windSpeed, windDirection
//  u3: U,W,theta,wy,V,phi,wx,psi,wz
//  u4: sailPosition
//
// Output:
//  y1: sailPosition, rudderPosition
//  y2: F_b (3-vector in body frame)
//  y3: M_b (3-vector in body frame)
//  y4: alpha, apparentWindDir, LRudder, DRudder, apparentWindSpeed, relativeCourseOverGround
//  y5: sailPositionRate
//
// AUTHOR:
//
// Copyright (C) James Goppert 2012
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
		graphics=arg1.graphics;
        exprs=graphics.exprs
		model=arg1.model;
        while %t do
            labels=[..
                'env: density of air, kg/m^3';..
                'env: density of water, kg/m^3';..
                'sail: area, m^2';..
                'sail: CD0';..
                'sail: CD2';..
                'sail: lift-curve slope';..
                'sail: stall angle, rad';..
                'sail: distance from mast to center of effort, m';..
                'sail: distance from mast to center of mass, m';..
                'rudder: distance to center of mass, m';..
                'rudder: CD0';..
                'rudder: CD2';..
                'rudder: area, m^2';..
                'rudder: stall angle, rad';..
                'rudder: lift-curve slope';..
                'hull: wetted area, m^2';..
                'hull: CD';..
                'hull: rotational damping coefficient'..
                ];
            [ok,rho,rhoW,s,cD0,cD2,cLAlpha,alphaStall,xSail,dSail,xRudder,cD0Rudder,..
                cD2Rudder, sRudder, alphaRudderStall, cLAlphaRudder, sWater, cDWater, cWaterRot,..
                exprs]=..
                getvalue('Set Sailboat Parameters',labels,..
                list(..
                    'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,..
                    'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,..
                    'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,..
                    'vec',1,'vec',1,'vec',1),exprs);
            if ~ok then break,end
                graphics.exprs=exprs;

            // set sizes
            nOut=[2;3;3;6;1];
            nIn=[2;2;9;1]

            model.out=[nOut];
            model.in=[nIn];
            [model,graphics,ok]=check_io(model,graphics,nIn,nOut,[],[])
            if ok then
                model.rpar=[rho,rhoW,s,cD0,cD2,cLAlpha,alphaStall,xSail,dSail,xRudder,cD0Rudder,..
                    cD2Rudder, sRudder, alphaRudderStall, cLAlphaRudder, sWater, cDWater, cWaterRot];
                graphics.exprs=exprs;
                x.graphics=graphics;
                x.model=model;
                break
            end
        end
	case 'define' then
		// set model properties
		model=scicos_model();
		model.sim=list('sci_sailboatForceMoments',4);

		nOut=[2;3;3;6;1];
		nIn=[2;2;9;1];

		model.in=nIn;
		model.out=nOut;
		model.blocktype='c';
		model.dep_ut=[%t %f];

        // parameters
        rho = 1.225;
        rhoW = 1000;
        s = 1;
        cD0 = .1;
        cD2 = .01;
        cLAlpha = 2*%pi;
        alphaStall = 20*%pi/180;
        xSail = 0.2;
        dSail = 0.2;
        xRudder = 0.5;
        cD0Rudder = 0.1;
        cD2Rudder = 0.01;
        sRudder = 0.05;
        alphaRudderStall = 20*%pi/180;
        cLAlphaRudder = 2;
        sWater = 1;
        cDWater = 0.03;
        cWaterRot = 5;
    
        model.rpar=[rho,rhoW,s,cD0,cD2,cLAlpha,alphaStall,xSail,dSail,xRudder,cD0Rudder,..
            cD2Rudder, sRudder, alphaRudderStall, cLAlphaRudder, sWater, cDWater, cWaterRot];
		
		// initialize strings for gui
        exprs=[..
            strcat(sci2exp(rho)),..
            strcat(sci2exp(rhoW)),..
            strcat(sci2exp(s)),..
            strcat(sci2exp(cD0)),..
            strcat(sci2exp(cD2)),..
            strcat(sci2exp(cLAlpha)),..
            strcat(sci2exp(alphaStall)),..
            strcat(sci2exp(xSail)),..
            strcat(sci2exp(dSail)),..
            strcat(sci2exp(xRudder)),..
            strcat(sci2exp(cD0Rudder)),..
            strcat(sci2exp(cD2Rudder)),..
            strcat(sci2exp(sRudder)),..
            strcat(sci2exp(alphaRudderStall)),..
            strcat(sci2exp(cLAlphaRudder)),..
            strcat(sci2exp(sWater)),..
            strcat(sci2exp(cDWater)),..
            strcat(sci2exp(cWaterRot))];

		// setup icon
		gr_i=['xstringb(orig(1),orig(2),[''sailboat'';''force &'';''moments''],sz(1),sz(2),''fill'');']
		x=standard_define([5 2],model,exprs,gr_i)
	end
endfunction

// vim:ts=4:sw=4
