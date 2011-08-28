// design for linear quadratic tracker
function lqtDesign(sys)
// lqtDesign
// Solved the linear quadratic tracker problem for a system.
// @param sys: linaer system
  [A,B,C,D]=abcd(sys);
  n=size(A,1);
  p=size(B,1);
  m=size(C,1);
  K=-ppol(A,B,-1*ones(n,1));
  Kn=sva(K,m);
  printf('State feedback poles:\n');
  disp(spec(A+B*K))
  printf('Output feedback poles:\n');
  disp(spec(A+B*Kn*C))
endfunction

