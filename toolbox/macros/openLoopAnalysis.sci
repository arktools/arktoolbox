// open loop statistics
function openLoopAnalysis(sys)
	if(typeof(sys)=='state-space') sys = ss2cleanTf(sys); end
	sse=1/(horner(sys,1e-10));
	if (sse>1e6) sse=%inf; end
    printf('\t\tgcf=%8.2f Hz\t\tsse=%8.2f\n',bw(tf2ss(sys),0),sse);
endfunction

