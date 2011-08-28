function [tt]=texprint2(a)
// text = texprint2(a) returns the Tex source code of the scilab variable a.
// a is a matrix (scalar, polynomial, rational) or a linear system
// (syslin list).
//!
//
// Copyright INRIA
//
// updated by James Goppert
// modfified to work with new \begin{pmatrix}/ \end{pmatrix} style
typ=type(a)

select typ
case 1 then  //scalars
  [m,n]=size(a)
  if norm(imag(a))<=%eps*norm(real(a)) then
    a=string(real(a))
  else
    a=string(a)
  end
  if m*n==0 then tt='\begin{pmatrix}',return,end
  if m*n<>1 then tt='\begin{pmatrix}',else tt='',end
  for l=1:m,tt=tt+strcat(a(l,:),'&')+'\\'; end
  tt=part(tt,1:length(tt)-4)+'\end{pmatrix}'
  tt=strsubst(tt,'%','')
case 2 then //polynomials
   [m,n]=size(a)
   if m*n<>1 then tt='\begin{pmatrix}',else tt='',end
   z=varn(a)
   nz=1;while part(z,nz)<>' ' then nz=nz+1,end
   z=part(z,1:nz-1)
//
   for l=1:m
     for k=1:n,tt=tt+pol2tex(a(l,k))+'&',end
     tt=part(tt,1:length(tt)-1)+'\\'
   end
   tt=part(tt,1:length(tt)-4)+'\end{pmatrix}'
   tt=strsubst(tt,'%','')
case 4 then //booleans
  [m,n]=size(a)
  x='F'+emptystr(a);x(a)='T';a=x;
  if m*n<>1 then tt='\begin{pmatrix}',else tt='',end
  for l=1:m,tt=tt+strcat(a(l,:),'&')+'\\'; end
  tt=part(tt,1:length(tt)-4)+'\end{pmatrix}'
case 8 then //int
  [m,n]=size(a);a=string(a)
  if m*n<>1 then tt='\begin{pmatris}',else tt='',end
  for l=1:m,tt=tt+strcat(a(l,:),'&')+'\\'; end
  tt=part(tt,1:length(tt)-4)+'\end{pmatrix}'

case 10 then //strings
  [m,n]=size(a)
  if m*n<>1 then tt='\begin{pmatrix}',else tt='',end
  for l=1:m,tt=tt+strcat(a(l,:),'&')+'\\'; end
  tt=part(tt,1:length(tt)-4)+'\end{pmatrix}'

case 16 then 
  a1=a(1)//transfer and linear systems
  select a1(1)
  case 'r' then //rationals
    num=a('num');a=a('den')
    [m,n]=size(a)
    if m*n<>1 then tt='\begin{pmatrix}',else tt='',end
    z=varn(a)
    nz=1;while part(z,nz)<>' ' then nz=nz+1,end
    z=part(z,1:nz-1)
    //
    for l=1:m
      for k=1:n,
	if degree(a(l,k))==0 then
	  num(l,k)=num(l,k)/coeff(a(l,k)),pol=1
	else
	  pol=0
	end
	nlk=pol2tex(num(l,k));
	if nlk=='0' then
	  tt=tt+'0&'
	else
	  if pol==1 then
	    tt=tt+nlk+'&'
	  else
	    dlk=pol2tex(a(l,k))
	    tt=tt+'\frac{'+nlk+'}{'+dlk+'}&',
	  end
	end
      end
      tt=part(tt,1:length(tt)-1)+'\\'
    end
    tt=part(tt,1:length(tt)-4)+'\end{pmatrix}'
    tt=strsubst(tt,'%','')
  case 'lss' //linear state space
    if a(7)=='c' then der=' \dot{x}',else der=' \stackrel{+}{X}',end
    debut='\begin{eqnarray}';fin='\end{eqnarray}'
    tt=debut+der+' &=& '+texprint2(a(2))+' X + '+...
	texprint2(a(3))+'U \\ \\ Y &=& '+texprint2(a(4))+' X '
    if norm(a(5),1)==0 then
      tt=tt+fin
    else
      tt=tt+' + '+texprint2(a(5))+fin
    end
  else
    execstr('tt=%'+a1(1)+'_texprint2(a)','errcatch')
  end
case 17  then
  a1=getfield(1,a)
  execstr('tt=%'+a1(1)+'_texprint2(a)','errcatch')
else
  execstr('tt=%'+typeof(a)+'_texprint2(a)','errcatch')
end
endfunction

