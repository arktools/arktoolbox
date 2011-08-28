function sys = pidCont(kP,kI,kD)
// continuous pid controller model, with zero order hold approximation
	sys = syslin('c',kP+kI/%s+%s*kD);
endfunction

