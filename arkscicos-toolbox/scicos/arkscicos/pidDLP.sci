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
  y=needcompile
  typ=list()
  graphics=arg1.graphics;
  exprs=graphics.exprs
  Btitre=..
    "Set block parameters"
  Exprs0=..
    ["y_min";"y_max";"w_cut";"kP";"kI";"kD";"i_min";"i_max"]
  Bitems=..
    ["y_min";"y_max";"w_cut";"kP";"kI";"kD";"i_min";"i_max"]
  Ss=..
    list("pol",-1,"pol",-1,"pol",-1,"pol",-1,"pol",-1,"pol",-1,"pol",-1,"pol",-1)
  scicos_context=struct()
     x=arg1
  ok=%f
  while ~ok do
    [ok,scicos_context.y_min,scicos_context.y_max,scicos_context.w_cut,scicos_context.kP,scicos_context.kI,scicos_context.kD,scicos_context.i_min,scicos_context.i_max,exprs]=getvalue(Btitre,Bitems,Ss,exprs)
    if ~ok then return;end
     %scicos_context=scicos_context
     sblock=x.model.rpar
     [%scicos_context,ierr]=script2var(sblock.props.context,%scicos_context)
     if ierr==0 then
       [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),%scicos_context)
   if ok then
          y=max(2,needcompile,needcompile2)
          x.graphics.exprs=exprs
          x.model.rpar=sblock
          break
   end
     else
       err=lasterror();
       if err<>[] then message(err);end
   ok=%f
     end
  end
case 'define' then
scs_m_1=scicos_diagram(..
        version="scicos4.4",..
        props=scicos_params(..
              wpar=[-68.08476284939,534.5438086935,161.4364305924,622.8078593352,835,640,0,30,836,..
              640,843,138,1.4],..
              Title=["SuperBlock","./"],..
              tol=[0.000001,0.000001,0.0000000001,31,0,0],..
              tf=30,..
              context=" ",..
              void1=[],..
              options=tlist(["scsopt","3D","Background","Link","ID","Cmap"],list(%t,33),[8,1],[1,5,2],..
              list([4,1,10,1],[4,1,2,1]),[0.8,0.8,0.8]),..
              void2=[],..
              void3=[],..
              doc=list()))
scs_m_1.objs(1)=scicos_block(..
                gui="CBLOCK4",..
                graphics=scicos_graphics(..
                         orig=[201.80689,330.5265],..
                         sz=[40,40],..
                         flip=%t,..
                         theta=0,..
                         exprs=list(..
                         ["pidDLP";
                         "n";
                         "[1,1;1,1]";
                         "[1;1]";
                         "[1,1;1,1]";
                         "[1;1]";
                         "[1]";
                         "[]";
                         "[]";
                         "[0;0;0;0]";
                         "list()";
                         "[kP;kI;kD;i_min;i_max;y_min;y_max;w_cut]";
                         "[]";
                         "list()";
                         "0";
                         "0";
                         "[]";
                         "y";
                         "n";
                         "";
                         ""],..
                         ["#include <scicos/scicos_block4.h>";
                         "";
                         "void pidDLP(scicos_block *block,int flag)";
                         "{";
                         "  /* init */";
                         "  if (flag == 4) {";
                         "   double * x = (double*)GetDstate(block);";
                         "   x[0] = get_scicos_time(); // set initial time";
                         "";
                         "  /* output computation */ ";
                         "  } else if(flag == 1) {";
                         "";
                         "    // real parameters";
                         "    double kP = block->rpar[0];";
                         "    double kI = block->rpar[1];";
                         "    double kD = block->rpar[2];";
                         "    double i_min = block->rpar[3];";
                         "    double i_max = block->rpar[4];";
                         "    double y_min = block->rpar[5];";
                         "    double y_max = block->rpar[6];";
                         "    double w_cut = block->rpar[7];";
                         "";
                         "    // inputs";
                         "    double * u1 = (double*)GetInPortPtrs(block,1); ";
                         "    double * u2 = (double*)GetInPortPtrs(block,2); ";
                         "    double r = u1[0];";
                         "    double v = u2[0];";
                         "";
                         "    // outputs";
                         "    double * y1 = (double*)GetOutPortPtrs(block,1); ";
                         "    double * y2 = (double*)GetOutPortPtrs(block,2); ";
                         "";
                         "    // states";
                         "    double * x = (double*)GetDstate(block);";
                         "    double t0 = x[0];";
                         "    double i0 = x[1];";
                         "    double e0 = x[2];";
                         "    double d0 = x[3];";
                         "";
                         "    double t = get_scicos_time();";
                         "    double dt = t-t0;";
                         "";
                         "    double e = r-v;";
                         "    double i = i0 + e*dt;";
                         "    double d = 0;";
                         "    if (dt > 1e-6) d = (e - e0)/dt;";
                         " ";
                         "    // low pass filter";
                         "    double alpha = w_cut*dt/(1+w_cut*dt);";
                         "";
                         "    // saturate i";
                         "    if (i > i_max) i = i_max;";
                         "    if (i< i_min) i = i_min;";
                         "";
                         "    // low pass";
                         "    d = alpha*d + (1-alpha)*d0;";
                         "";
                         "    // compute error";
                         "    double y = kP*e + kI*i + kD*d;";
                         "    ";
                         "    // saturate y";
                         "    if (y > y_max) y = y_max;";
                         "    if (y< y_min) y = y_min;";
                         "";
                         "    // save state";
                         "    x[0] = t;";
                         "    x[1] = i;";
                         "    x[2] = e;";
                         "    x[3] = d;";
                         " ";
                         "    // save output";
                         "    y1[0] = y;";
                         "    y2[0] = e;";
                         "";
                         "  /* ending */";
                         "  } else  if (flag == 5) {";
                         "   ";
                         "  }";
                         "}";
                         "";
                         "";
                         "";
                         "";
                         "";
                         "";
                         "";
                         "";
                         "";
                         "";
                         ""]),..
                         pin=[5;7],..
                         pout=[3;9],..
                         pein=11,..
                         peout=[],..
                         gr_i=list("xstringb(orig(1),orig(2),[''CBlock4''],sz(1),sz(2),''fill'');",8),..
                         id="",..
                         in_implicit=["E";"E"],..
                         out_implicit=["E";"E"]),..
                model=scicos_model(..
                         sim=list("pidDLP",2004),..
                         in=[1;1],..
                         in2=[1;1],..
                         intyp=[1;1],..
                         out=[1;1],..
                         out2=[1;1],..
                         outtyp=[1;1],..
                         evtin=1,..
                         evtout=[],..
                         state=[],..
                         dstate=[0;0;0;0],..
                         odstate=list(),..
                         rpar=[1;1;1;-1;1;-1;1;10],..
                         ipar=[],..
                         opar=list(),..
                         blocktype="c",..
                         firing=[],..
                         dep_ut=[%t,%f],..
                         label="",..
                         nzcross=0,..
                         nmode=0,..
                         equations=list()),..
                doc=list())
scs_m_1.objs(2)=scicos_block(..
                gui="OUT_f",..
                graphics=scicos_graphics(..
                         orig=[270.37832,347.19317],..
                         sz=[20,20],..
                         flip=%t,..
                         theta=0,..
                         exprs="1",..
                         pin=3,..
                         pout=[],..
                         pein=[],..
                         peout=[],..
                         gr_i=list(" ",8),..
                         id="",..
                         in_implicit="E",..
                         out_implicit=[]),..
                model=scicos_model(..
                         sim="output",..
                         in=-1,..
                         in2=-2,..
                         intyp=-1,..
                         out=[],..
                         out2=[],..
                         outtyp=1,..
                         evtin=[],..
                         evtout=[],..
                         state=[],..
                         dstate=[],..
                         odstate=list(),..
                         rpar=[],..
                         ipar=1,..
                         opar=list(),..
                         blocktype="c",..
                         firing=[],..
                         dep_ut=[%f,%f],..
                         label="",..
                         nzcross=0,..
                         nmode=0,..
                         equations=list()),..
                doc=list())
scs_m_1.objs(3)=scicos_link(..
                  xx=[250.3783185714;270.37832],..
                  yy=[357.1931666667;357.19317],..
                  id="",..
                  thick=[0,0],..
                  ct=[1,1],..
                  from=[1,1,0],..
                  to=[2,1,1])
scs_m_1.objs(4)=scicos_block(..
                gui="IN_f",..
                graphics=scicos_graphics(..
                         orig=[153.23546,347.19317],..
                         sz=[20,20],..
                         flip=%t,..
                         theta=0,..
                         exprs=["1";"-1";"-1"],..
                         pin=[],..
                         pout=5,..
                         pein=[],..
                         peout=[],..
                         gr_i=list(" ",8),..
                         id="",..
                         in_implicit=[],..
                         out_implicit="E"),..
                model=scicos_model(..
                         sim="input",..
                         in=[],..
                         in2=[],..
                         intyp=1,..
                         out=-1,..
                         out2=-2,..
                         outtyp=-1,..
                         evtin=[],..
                         evtout=[],..
                         state=[],..
                         dstate=[],..
                         odstate=list(),..
                         rpar=[],..
                         ipar=1,..
                         opar=list(),..
                         blocktype="c",..
                         firing=[],..
                         dep_ut=[%f,%f],..
                         label="",..
                         nzcross=0,..
                         nmode=0,..
                         equations=list()),..
                doc=list())
scs_m_1.objs(5)=scicos_link(..
                  xx=[173.23546;193.2354614286],..
                  yy=[357.19317;357.1931666667],..
                  id="",..
                  thick=[0,0],..
                  ct=[1,1],..
                  from=[4,1,0],..
                  to=[1,1,1])
scs_m_1.objs(6)=scicos_block(..
                gui="IN_f",..
                graphics=scicos_graphics(..
                         orig=[153.23546,333.85983],..
                         sz=[20,20],..
                         flip=%t,..
                         theta=0,..
                         exprs=["2";"-1";"-1"],..
                         pin=[],..
                         pout=7,..
                         pein=[],..
                         peout=[],..
                         gr_i=list(" ",8),..
                         id="",..
                         in_implicit=[],..
                         out_implicit="E"),..
                model=scicos_model(..
                         sim="input",..
                         in=[],..
                         in2=[],..
                         intyp=1,..
                         out=-1,..
                         out2=-2,..
                         outtyp=-1,..
                         evtin=[],..
                         evtout=[],..
                         state=[],..
                         dstate=[],..
                         odstate=list(),..
                         rpar=[],..
                         ipar=2,..
                         opar=list(),..
                         blocktype="c",..
                         firing=[],..
                         dep_ut=[%f,%f],..
                         label="",..
                         nzcross=0,..
                         nmode=0,..
                         equations=list()),..
                doc=list())
scs_m_1.objs(7)=scicos_link(..
                  xx=[173.23546;193.2354614286],..
                  yy=[343.85983;343.8598333333],..
                  id="",..
                  thick=[0,0],..
                  ct=[1,1],..
                  from=[6,1,0],..
                  to=[1,2,1])
scs_m_1.objs(8)=scicos_block(..
                gui="OUT_f",..
                graphics=scicos_graphics(..
                         orig=[270.37832,333.85983],..
                         sz=[20,20],..
                         flip=%t,..
                         theta=0,..
                         exprs="2",..
                         pin=9,..
                         pout=[],..
                         pein=[],..
                         peout=[],..
                         gr_i=list(" ",8),..
                         id="",..
                         in_implicit="E",..
                         out_implicit=[]),..
                model=scicos_model(..
                         sim="output",..
                         in=-1,..
                         in2=-2,..
                         intyp=-1,..
                         out=[],..
                         out2=[],..
                         outtyp=1,..
                         evtin=[],..
                         evtout=[],..
                         state=[],..
                         dstate=[],..
                         odstate=list(),..
                         rpar=[],..
                         ipar=2,..
                         opar=list(),..
                         blocktype="c",..
                         firing=[],..
                         dep_ut=[%f,%f],..
                         label="",..
                         nzcross=0,..
                         nmode=0,..
                         equations=list()),..
                doc=list())
scs_m_1.objs(9)=scicos_link(..
                  xx=[250.3783185714;270.37832],..
                  yy=[343.8598333333;343.85983],..
                  id="",..
                  thick=[0,0],..
                  ct=[1,1],..
                  from=[1,2,0],..
                  to=[8,1,1])
scs_m_1.objs(10)=scicos_block(..
                 gui="CLKINV_f",..
                 graphics=scicos_graphics(..
                          orig=[211.80689,406.24079],..
                          sz=[20,30],..
                          flip=%t,..
                          theta=0,..
                          exprs="1",..
                          pin=[],..
                          pout=[],..
                          pein=[],..
                          peout=11,..
                          gr_i=list(..
                          ["xo=orig(1);yo=orig(2)+sz(2)/3";"xstringb(xo,yo,string(prt),sz(1),sz(2)/1.5)"],..
                          8),..
                          id="",..
                          in_implicit=[],..
                          out_implicit=[]),..
                 model=scicos_model(..
                          sim="input",..
                          in=[],..
                          in2=[],..
                          intyp=1,..
                          out=[],..
                          out2=[],..
                          outtyp=1,..
                          evtin=[],..
                          evtout=1,..
                          state=[],..
                          dstate=[],..
                          odstate=list(),..
                          rpar=[],..
                          ipar=1,..
                          opar=list(),..
                          blocktype="d",..
                          firing=-1,..
                          dep_ut=[%f,%f],..
                          label="",..
                          nzcross=0,..
                          nmode=0,..
                          equations=list()),..
                 doc=list())
scs_m_1.objs(11)=scicos_link(..
                   xx=[221.80689;221.80689],..
                   yy=[406.24079;376.2407857143],..
                   id="",..
                   thick=[0,0],..
                   ct=[5,-1],..
                   from=[10,1,0],..
                   to=[1,1,1])
  model=scicos_model()
  model.sim="csuper"
  model.in=[-1;-1]
  model.in2=[-2;-2]
  model.intyp=[-1;-1]
  model.out=[-1;-1]
  model.out2=[-2;-2]
  model.outtyp=[-1;-1]
  model.evtin=1
  model.evtout=[]
  model.state=[]
  model.dstate=[]
  model.odstate=list()
  model.rpar=scs_m_1
  model.ipar=1
  model.opar=list()
  model.blocktype="h"
  model.firing=[]
  model.dep_ut=[%f,%f]
  model.label=""
  model.nzcross=0
  model.nmode=0
  model.equations=list()
  y_min=-1
  y_max=1
  w_cut=10
  kP=1
  kI=1
  kD=1
  i_min=-1
  i_max=1
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
