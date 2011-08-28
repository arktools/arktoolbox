function sys = unityFeedback(y,u,G,H)

    // sizes
    nY = size(G,1);
    nU = size(G,2);
    nH = size(H,2);

    // convert to state space form
    if (typeof(G)=="rational") G = tf2ss(G); end;
    if (typeof(H)=="state-space") H = ss2tf(H); end;
    if (typeof(G)~="state-space")
        error("G must be a rational or state-space variable");
    end
    if (typeof(H)~="rational")
        error("H must be a rational or state-space variable");
    end

    // check sizes
    if (size(y,1)~=1 | size(u,1)~=1 | size(H,1)~=1)
        error("y, u and H must be row vectors");
    end
    if (size(u,2)~=nH | size(y,2)~=nH)
        error("y, u, and H, must have the same length");
    end

   	C = zeros(nH,nY);
	for (i=1:nH) C(i,y(i)) = 1; end;
	D = zeros(nU,nH);
	for (i=1:nH) D(u(i),i) = 1; end;
	oltf = G*D*diag(H);
    nPoles=size(abcd(H),1)+size(abcd(G),1);
    //printf("nPoles: %d\n",nPoles);
    sys=minssAutoTol((eye(nY,nY)+oltf*C)\[G,oltf],nPoles);
endfunction
// vim:sw=4:ts=4:expandtab
