// design an lqr controller
function K=lqrDesign(sys,Q,R)
	n=size(sys.A,1);
	m=size(sys.B,2);
	Big=sysdiag(Q,R);
	[w,wp]=fullrf(Big);
	C1=wp(:,1:n);
	D12=wp(:,(n+1):$); 
	P=syslin('c',sys.A,sys.B,C1,D12);
	K=lqr(P);  
endfunction

