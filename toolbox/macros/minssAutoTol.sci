function sysMin = minssAutoTol(sys,nPoles)
// auto trims state space system for proper
// number of poles
    tol = 1e-100;
    while(1)
        sys = minss(sys,tol)
		nSysPoles = size(sys.A,1);
        if (nSysPoles <= nPoles | tol > 1e-1) break; end;
		tol = tol*2;
	end
    if (nSysPoles == nPoles)
        //printf("\t\tconverged with right number of poles at %e\n",tol);
    elseif (nSysPoles < nPoles)
        printf("\t\t%d pole zero cancellation(s) occurred.\n",nPoles-nSysPoles);
    else
	    printf("\t\tWARNING: Failed to converge with correct number of poles.\n");
	    printf("\t\t\treal: %d calculated: %d\n",nRealPoles,nPoles);
    end
    sysMin = sys;
endfunction
// vim:ts=4:sw=4:expandtab
