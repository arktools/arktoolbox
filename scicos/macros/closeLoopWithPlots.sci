function [f,s,u,fIndex] = closeLoopWithPlots(name,fIndex,yi,ui,s,y,u,H,loopType)
	s0 = ss2cleanTf(s);
	[s,u] = closeLoop(yi,ui,s,y,u,H,loopType);
	s1 = ss2cleanTf(s);

	f=scf(fIndex); clf(fIndex);
	f.figure_name=name+'_bode';
	f.figure_size = [800,600];
	set_posfig_dim(f.figure_size(1),f.figure_size(2));

	bode([s0(yi,ui);H*s0(yi,ui);s1(yi,evstr('u.'+y.str(yi)))],..
		0.01,99,.01,..
		['open loop';'compensated open loop';'compensated closed loop']);

	xs2eps(fIndex,f.figure_name);
	fIndex = fIndex +1;

	f=scf(fIndex); clf(fIndex);
	f.figure_name=name+'_evans';
	f.figure_size = [800,400];
	set_posfig_dim(f.figure_size(1),f.figure_size(2));

	subplot(1,2,1)
	evans(s0(yi,ui),100);
	title(gca(),'Uncompensated Root Locus');
	mtlb_axis([-10,10,-10,10]);

	subplot(1,2,2)
	evans(H*s0(yi,ui),10);
	title(gca(),'Compensated Root Locus');
	mtlb_axis([-10,10,-10,10]);

	// save
	xs2eps(fIndex,f.figure_name);
	fIndex = fIndex +1;

endfunction
