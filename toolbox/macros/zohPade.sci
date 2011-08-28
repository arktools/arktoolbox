function sys = zohPade(controlFrequency)
// zero order hold pade approximation
// controlFrequency must be a row vector
// see Stevens and Lewis pg. 617
	sys = [];
	mode(1)
	for i=1:size(controlFrequency,2)
		controlPeriod = 1/controlFrequency(1,i);
		sys(i,1) = (1-%s*controlPeriod/6)/(1 + %s*controlPeriod/3);
	end
endfunction
