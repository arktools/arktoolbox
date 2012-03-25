function [x,y,typ]=pidDLP(job,arg1,arg2)
//
// pidDFB.sci
//
// Digital PID controller with derivative feedback.
//
// USAGE:
//
// input:
//  [1]  r, reference signal
//  [2]  v, feedback value 
//
// output:
//  [1]  e, error (reference - feedback)
//  [2]  y, output
//
// Copyright (C) James Goppert 2012 <jgoppert@users.sourceforge.net>
//
// car.sci is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// car.sci is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  If not, see <http://www.gnu.org/licenses/>.
//
mode(-1)
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
        x=arg1
        graphics=arg1.graphics;
        exprs=graphics.exprs
        model=arg1.model;
        title=..
            "Set block parameters"
        labels=..
            ["y_min";"y_max";"w_cut";"kP";"kI";"kD";"i_min";"i_max"]
        types=..
            list("vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1)
  
        while %t do

            [ok,y_min,y_max,w_cut,kP,kI,kD,i_min,i_max,exprs]=getvalue(title,labels,types,exprs)
            if ~ok then break,end

            graphics.exprs=exprs;

            if ok then
                model.rpar=[kP,kI,kD,i_min,i_max,y_min,y_max,w_cut];
                graphics.exprs=exprs
                x.graphics=graphics;
                x.model=model;
                break
            end
        end

    case 'define' then
        model=scicos_model()
        model.sim=list('sci_pidDLP',4);
        model.in=[2]
        model.out=[2]
        model.evtin=1
        model.dstate=[0;0;0;0];
        y_min=-1
        y_max=1
        w_cut=10
        kP=1
        kI=1
        kD=1
        i_min=-1
        i_max=1
        model.rpar=[kP,kI,kD,i_min,i_max,y_min,y_max,w_cut];
        model.ipar=1
        model.blocktype='d'
        model.dep_ut=[%t,%f]
  
        exprs=[sci2exp(y_min,0);sci2exp(y_max,0);sci2exp(w_cut,0);sci2exp(kP,0);sci2exp(kI,0);sci2exp(kD,0);sci2exp(i_min,0);sci2exp(i_max,0);]
        gr_i=list(..
            ["xstring(orig(1)+sz(1)*0.23,orig(2)+sz(2)*0.51,[""w/ d/dt""]);";
            "xstring(orig(1)+sz(1)*0.23,orig(2)+sz(2)*0.67,[""Discrete""]);";
            "xstring(orig(1)+sz(1)*0.23,orig(2)+sz(2)*0.86,[""PID""]);";
            "xstring(orig(1)+sz(1)*0.06,orig(2)+sz(2)*0.72,[""r""]);";
            "xstring(orig(1)+sz(1)*0.06,orig(2)+sz(2)*0.34,[""v""]);";
            "xstring(orig(1)+sz(1)*0.91,orig(2)+sz(2)*0.35,[""e""]);";
            "xstring(orig(1)+sz(1)*0.89,orig(2)+sz(2)*0.73,[""y""]);";
            "xstring(orig(1)+sz(1)*0.23,orig(2)+sz(2)*0.15,[""Pass Filt.""]);";
            "xstring(orig(1)+sz(1)*0.23,orig(2)+sz(2)*0.34,[""Low""]);"],8)
        x=standard_define([4,4],model,exprs,gr_i)
    end
endfunction
