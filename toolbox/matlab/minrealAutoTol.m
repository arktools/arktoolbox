function sysMin = minrealAutoTol(sys,nPoles)
% auto trims state space system for proper
% number of poles
%
% usage newSys = minssAutoTol(sys,nPoles)
%
% input:
%  sys - original system
%  nPoles - number of poles desired for system
%
% output:
%  newSys - system ofer minimum realization
%
%
% Copyright 2011 James Goppert
% Released under GPL v3 License
%
    tol = 1e-20;
    while(1)
        sys = minreal(sys,tol);
		nSysPoles = order(sys);
        fprintf('nSysPoles: %d tol: %e\n',nSysPoles,tol);
        if (nSysPoles <= nPoles | tol > 1) break; end;
		tol = tol*1.1;
	end
    if (nSysPoles == nPoles)
        %fprintf('\t\tconverged with right number of poles at %e\n',tol);
    elseif (nSysPoles < nPoles)
        fprintf('\t\t%d pole zero cancellation(s) occurred.\n',nPoles-nSysPoles);
    else
	    fprintf('\t\tWARNING: Failed to converge with correct number of poles.\n');
	    fprintf('\t\t\treal: %d calculated: %d\n',nSysPoles,nPoles);
    end
    sysMin = sys;
end
% vim:ts=4:sw=4:expandtab
