function [x,y,typ]=randn(job,arg1,arg2)
// Copyright Alan Kim
mode(-1);
x=[];y=[];typ=[];
select job
case 'plot' then //normal  position
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
  if size(exprs,'*')==14 then exprs(9)=[],end //compatiblity
  while %t do
    [ok,flag,seed_c,exprs]=getvalue([
	'Set Random generator block parameters';
	'flag = 0 : Uniform distribution A is min and A+B max';
	'flag = 1 : Normal distribution A is mean and B deviation';
	' ';
	'A and B must be matrix with equal sizes'],..
	['Flag';'SEED'],..
	list('vec',1,'mat',[1 2]),exprs)
    if ~ok then break,end
    if flag<>0&flag<>1 then
      message('flag must be equal to 1 or 0')
    else
      junction_name='sci_randn';
      model.dstate=[seed_c(1);0*real(a(:))]
      ot=1
      if ok then
         [model,graphics,ok]=set_io(model,graphics,list([-1 ;-2],ot),list([-1; -2],ot),1,[])
         if ok then 
            model.sim=list(junction_name,4)
            graphics.exprs=exprs
            model.ipar=flag
            x.graphics=graphics;x.model=model
            break
         end
      end
    end
  end
case 'define' then
  dt=0
  flag=1
  junction_name='sci_randn';
  funtyp=4;
  model=scicos_model()
  model.sim=list(junction_name,funtyp)
  model.in=[1;1]
  model.in2=[1;1]
  model.intyp=1
  model.out=[1]
  model.out2=[1]
  model.outtyp=1
  model.evtin=1
  model.evtout=[]
  model.state=[]
  model.dstate=[int(rand()*(10^7-1));0]
  model.ipar=flag
  model.blocktype='d' 
  model.firing=[]
  model.dep_ut=[%f %f]

  exprs=[string(flag);sci2exp([model.dstate(1) int(rand()*(10^7-1))])]
  gr_i=['txt=[''randn''];';
    'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
  x=standard_define([3 2],model,exprs,gr_i)
end
endfunction
