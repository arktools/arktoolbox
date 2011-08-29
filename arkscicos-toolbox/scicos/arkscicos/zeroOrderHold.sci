function [x,y,typ]=zeroOrderHold(job,arg1,arg2)
//
// zeroOrderHOld.sci
//
// USAGE:
//
// gui config:
// inherit : whether or not to inherit event
// reset : whether or not to except an external reset
// initial value :  value the block starts with
//
// event input:
// 1 (if inherit %t) : timer
// 2 (if reset %t): reset event
// 
// input:
// 1 : u(k)
// 2 (if reset %t): reset value
//
// output : u(k-1)
//
// Copyright (C) James Goppert, Alan Kim 2011 <jgoppert@users.sourceforge.net>
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
// You should have received a copy of the GNU Geeral Public License along
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
    while %t
        [ok,z,inh,reset,exprs]=getvalue('Set 1/z block parameters',..
        ['Initial condition';'Inherit (no:0, yes:1)';'Reset (no:0, yes:1)'],...
              list('mat',[-1 -2],'vec',1,'vec',1),exprs)

        if ~ok then break,end

        if isempty(z) then z=0,end

        // size
        if size(z,"*")==1 then 
            out=[-1,-2],
        else
            out=[size(z,1) size(z,2)];
        end

        // type
        if do_get_type(z)==1 then
            ot=-1
        else
            ot=do_get_type(z)
        end

        // input/output size/type
        if reset then   
            in=[out;out];
            it=[ot;ot];
        else 
            in=out
            it=ot
        end

        // port for time
        if inh then
            evtPortTime = 0;
        else
            evtPortTime = 1;
        end

        // port for reset
        if reset then
            evtPortReset = evtPortTime + 1;
        else
            evtPortReset = 0;
        end

        // graphics
        if ok then
            [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),ones(1-inh+reset,1),[])
            model.dstate=z
            model.ipar=[evtPortTime;evtPortReset];
        end

        if ok then
            graphics.exprs=exprs;
            x.graphics=graphics;x.model=model
            break
        end
    end
//case 'compile'
    //model=arg1
    //sz=[model.in model.in2]
    //typ=model.intyp
    //z=model.dstate
    //if size(z,'*')==1 then 
        //z(1:sz(1),1:sz(2))=z
    //elseif ~isequal(sz,size(z)) then
        //error("state has size "+sci2exp(size(z))+" but input/output has size "+sci2exp(sz))
    //elseif do_get_type(z)>1 then
        //if ~isequal(do_get_type(z),typ) then
            //error("state has type "+string(do_get_type(z))+" but input/output has type "+sci2exp(typ))
        //end
    //elseif do_get_type(z)==1 then
        //select typ
        //case 2
            //z=z+0*%i
        //case 3
            //z=int32(z)
        //case 4
            //z=int16(z)
        //case 5
            //z=int8(z)
        //case 6
            //z=uint32(z)
        //case 7
            //z=uint16(z)
        //case 8
            //z=uint8(z)
        //case 9
            //z=z>0
        //end
    //end

    //if size(z,'*')==1 & typ==1 then
        //model.sim=list('sci_zeroOrderHold',4);
        //model.dstate=z(:);
        //model.odstate=list();
    //else
        //model.sim=list('sci_zeroOrderHold',4)
        //model.odstate=list(z);
        //model.dstate=[];
    //end
    //x=model

case 'define' then
    z=0
    inh=0
    reset=0
    evtPortTime=1
    evtPortReset=0
    exprs=string([z;inh;reset])
    model=scicos_model()
    model.sim=list('sci_zeroOrderHold',4) 
    model.in=-1
    model.in2=-2
    model.out=-1
    model.out2=-2
    model.evtin=1
    model.dstate=z
    model.ipar=[evtPortTime;evtPortReset];
    model.blocktype='d'
    model.dep_ut=[%f %f]
    gr_i='xstringb(orig(1),orig(2),''1/z'',sz(1),sz(2),''fill'')'
    x=standard_define([2 2],model,exprs,gr_i)
end

endfunction

// vim:ts=4:sw=4:expandtab

