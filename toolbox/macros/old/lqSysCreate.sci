// create a new linear quadratic system
function sub=lqSysCreate(name,orig,XI,UI,YI)
    designWorked=0;
	info=orig.info;

	// define lq system
	sub.name=name;
	sub.XI=XI;
	sub.UI=UI;
	sub.trim.X=orig.trim.X(XI);
	sub.trim.XP=orig.trim.XP(XI);
	sub.trim.Y=orig.trim.Y(YI);
	sub.trim.U=orig.trim.U(UI);
	sub.Q=orig.Q(XI,XI);
	sub.R=orig.R(UI,UI);
	sub.sys=syslin('c',orig.sys.A(XI,XI),orig.sys.B(XI,UI),..
		orig.sys.C(YI,XI),orig.sys.D(YI,UI));

	// define indices/ strings for sub system
	sub.info.x=defineIndex(info.x.str([XI]));
	sub.info.y=defineIndex(info.y.str([YI]));
	sub.info.u=defineIndex(info.u.str([UI]));

	// design controller

	// check for detectability and stabilizability 
	rankTol=.001;
	n=size(sub.sys.A,1);
	[nS,nC]=st_ility(sub.sys,rankTol);
	[k1,k2]=dt_ility(sub.sys,rankTol);
	nO=n-k2;
	nD=n-k1;	
	printf('\t\tstate dim n=%f\n',n);
	printf('\t\tcontrollable subspace dim = %f\n',nC);   
	printf('\t\tstabilizable subspace dim = %f\n',nS);   
	printf('\t\tobservable subspace dim = %f\n',nO);   
	printf('\t\tdetectable subspace dim = %f\n',nD);   
	if (nS<n)
		printf('\t\tsystem is not stabilizable\n');
	end
	if (nD<n)
		printf('\t\tsystem is not detectable\n');
    end

	// if stabilizable then desing state feedback controller
	if (nS==n)
		printf('\t\tsystem is stabilizable\n');
		printf('\t\tdesigning state feedback controller\n');
		sub.K=lqrDesign(sub.sys,sub.Q,sub.R);
		ev=spec(sub.sys.A+sub.sys.B*sub.K);
		printf('\t\tslowest time constant: %f sec\n',1/min(abs(ev)));
		[maxK,maxKI]=maxi(abs(sub.K));
		if (size(maxKI)==1) maxKI(2)=maxKI(1); maxKI(1)=1; end;
		printf('\t\tmax (abs) gain: %f u: %s x: %s\n', maxK,..
		  info.u.str(UI(maxKI(1))), info.x.str(XI(maxKI(2))));
		[minK,minKI]=mini(abs(sub.K));
		if (size(minKI)==1) minKI(2)=minKI(1); minKI(1)=1; end;
			printf('\t\tmin (abs) gain: %f u: %s x: %s\n', minK,..
		  	info.u.str(UI(minKI(1))), info.x.str(XI(minKI(2))));
		if (max(real(ev))>0)
		  	printf('\t\tcontrolled system unstable!!\n');
		else
		  	designWorked=1;
		end
    end
  
    // did design work?
    if (designWorked)
    	printf('\t\tdesign complete\n');
    else
      	printf('\t\tdesign failed\n');
		sub.K=zeros(size(sub.UI,2),size(sub.XI,2))
    end
  
endfunction
