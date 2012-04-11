// analyze linear quadratic design
function lqSysAnalysis(lqSys)
	printf('\tController Name: %s\n',lqSys.name);
	A=lqSys.sys.A;
	B=lqSys.sys.B;
	K=lqSys.K;
	printf('\t\tslowest controlled pole: %f sec\n',1/max(spec(A+B*K)));
endfunction

