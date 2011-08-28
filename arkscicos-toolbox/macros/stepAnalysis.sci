function [f,fIndex] =stepAnalysis(s,model,channel,fIndex,steps,yLabel,y,u,r)

	yCh = evstr('y.'+channel);
	uCh = evstr('u.'+channel);
	rCh = evstr('r.'+channel);

	// setup figure
	f=scf(fIndex); clf(fIndex);
	f.figure_name=channel + ' step responses';
	f.figure_size = [800,600];
	set_posfig_dim(f.figure_size(1),f.figure_size(2));
	xlabel('t, seconds');
	ylabel(yLabel);

	// for  several step sizes
	for step = steps

		// reference input signal
		rSignal = struct();
		rSignal.time = 0;
		rSignal.values = zeros(1,size(r.str,1));
		rSignal.values(1,rCh) = step;

		// non-linear simulation
		scicos_simulate(model);
		t = xSignal.time;
		yNLin = xSignal.values;

		// linear simulation
		yLin = csim('step',t,step*s(yCh,uCh))';
		plot(t,[yLin,yNLin(:,yCh)]);
	end

	// plotting
	legend(['linear','non-linear'])
	xs2eps(fIndex,channel+'_steps');
	fIndex = fIndex +1;

endfunction
