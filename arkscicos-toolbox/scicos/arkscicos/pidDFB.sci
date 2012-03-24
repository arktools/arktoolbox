function [x,y,typ]=pidDFB(job,arg1,arg2)
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
  typ=list()
  graphics=arg1.graphics;
  exprs=graphics.exprs
  Btitre=..
    "Set block parameters"
  Exprs0=..
    ["y_min";"y_max";"kP";"kI";"kD";"i_min";"i_max"]
  Bitems=..
    ["y_min";"y_max";"kP";"kI";"kD";"i_min";"i_max"]
  Ss=..
    list("pol",-1,"pol",-1,"pol",-1,"pol",-1,"pol",-1,"pol",-1,"pol",-1)

  x=arg1
  ok=%f
  while ~ok do
    [ok,y_min,y_max,kP,kI,kD,i_min,i_max,exprs]=getvalue(Btitre,Bitems,Ss,exprs)
   if ~ok then return;end
   if ok then
        x.model.rpar=[kP,kI,kD,i_min,i_max,y_min,y_max];
          x.graphics.exprs=exprs
          break
   end
     else
       err=lasterror();
       if err<>[] then message(err);end
   ok=%f
     end
  end
case 'define' then
  model=scicos_model()
  model.sim=list('sci_pidDFB',4);
  model.in=[-1;-1;-1]
  model.in2=[-2;-2;-2]
  model.intyp=[-1;-1;-1]
  model.out=[-1;-1]
  model.out2=[-2;-2]
  model.outtyp=[-1;-1]
  model.evtin=1
  model.evtout=[]
  model.state=[]
  model.dstate=[]
  model.odstate=list()
  y_min=-1
  y_max=1
  kP=1
  kI=0
  kD=1
  i_min=-1
  i_max=1
  model.rpar=[kP,kI,kD,i_min,i_max,y_min,y_max];
  model.ipar=1
  model.opar=list()
  model.blocktype="c"
  model.firing=[]
  model.dep_ut=[%f,%f]
  model.label=""
  model.nzcross=0
  model.nmode=0
  model.equations=list()
  exprs=[sci2exp(y_min,0);sci2exp(y_max,0);sci2exp(kP,0);sci2exp(kI,0);sci2exp(kD,0);sci2exp(i_min,0);sci2exp(i_max,0);]
  gr_i=list(..
       ["xstring(orig(1)+sz(1)*0.26,orig(2)+sz(2)*0.75,[""PID""]);";
       "xstring(orig(1)+sz(1)*0.26,orig(2)+sz(2)*0.53,[""Discrete""]);";
       "xstring(orig(1)+sz(1)*0.06,orig(2)+sz(2)*0.79,[""r""]);";
       "xstring(orig(1)+sz(1)*0.06,orig(2)+sz(2)*0.51,[""v""]);";
       "xstring(orig(1)+sz(1)*0.91,orig(2)+sz(2)*0.35,[""e""]);";
       "xstring(orig(1)+sz(1)*0.89,orig(2)+sz(2)*0.73,[""y""]);";
       "xstring(orig(1)+sz(1)*0.05,orig(2)+sz(2)*0.23,[""dv""]);";
       "xstring(orig(1)+sz(1)*0.25,orig(2)+sz(2)*0.31,[""d/dt FB""]);"],8)
  x=standard_define([4,4],model,exprs,gr_i)
end
endfunction
