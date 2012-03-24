function [x,y,typ]=pidDLP(job,arg1,arg2)
//Generated from SuperBlock on 14-Mar-2011
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
        Btitre=..
            "Set block parameters"
        Bitems=..
            ["y_min";"y_max";"w_cut";"kP";"kI";"kD";"i_min";"i_max"]
        Ss=..
            list("pol",-1,"pol",-1,"pol",-1,"pol",-1,"pol",-1,"pol",-1,"pol",-1,"pol",-1)
  
        while %t do
            [ok,y_min,y_max,w_cut,kP,kI,kD,i_min,i_max,exprs]=getvalue(Btitre,Bitems,Ss,exprs)
            if ~ok then break,end

            graphics.exprs=exprs;

            if ok then
                model.rpar=[kP,kI,kD,i_min,i_max,y_min,y_max,w_cut];
                graphics.exprs=exprs
                x.grpahics=graphics;
                x.model=model;
                break
            end
        end

    case 'define' then
        model=scicos_model()
        model.sim=list('sci_pidDLB',4);
        model.in=[-1;-1]
        model.out=[-1;-1]
        model.evtin=1
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
        model.blocktype="c"
        model.dep_ut=[%f,%f]
  
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
