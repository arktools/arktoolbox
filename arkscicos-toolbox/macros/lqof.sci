mode(-1);
function [K,gradopt,info] = lqof(problemType,K0,varargin)
// linear quaratic output feedback tracker/regulator design function
// input
// 		problem type : "R" regulator, "T" tracker
// 		K0 			: initial gain guess
// 		varargin  	: see below
// output
// 		K  			: optimal gain 
// 		gradopt	 	: optimal gradient
// 		info 		: ind, (0) correct behaviour, (1) error
//
// 	varargin:
// 		1: problem type
// 			"R" : LQR - linear quadratic regulator
// 			"T" : LQT - linear quadratic tracker
// 		for the rest of the inputs see the calling examples
// 		below
//
// Linear Quadratic Regulator:
// 	J = 1/2* integral(t^k*x'.P.x + x'.Q.x + u'.R.u)dt
//  dx = A.x + B.u
//  y = C.x
//
// calling for LQR problem:
// 	lqof("R",K0,P,Q,R,timeK,A,B,C); 
//
//  timeK is the power of t^k, (timeK = 0 disables time weighting)
//
// Linear Quadratic Tracker:
// 	J = 1/2 * integral(t^k*~x'.P.~x + ~x'.Q.~x + ~u.R.~u)dt + 1/2*eBar'.V.eBar
//  dx = A.x + B.u
//  y = C.x + F.r
//  z = H.z
//
// calling for LQT problem:
// 	lqof("T",K0,P,Q,R,V,timeK,A,B,C,G,F,H)
//
// pg. 408,428,440 Lewis and Stevens, Aicraft Control and Simulation
//
// See also riccati
//
// (C) James Goppert 2011, Released under GPL v3 license.

// start nested function

	// extracts data from variable input vector for the problem
	function [P,Q,R,V,A,B,C,G,F,H,nX,nY,nU,nR,r0,KFixed] = processInputs(varlist)

		// initialize variables
		P=[]; Q=[]; R=[]; V=[];
		A=[]; B=[]; C=[]; G=[]; F=[]; H=[];
		nVariableInputs = length(varlist);
		if (problemType=="R")
			if (nVariableInputs~=7)
				printf("variable list length : %d",nVariableInputs);
				error("length of variable list wrong");
			end
			// performance index 
			P=varlist(1);
			Q=varlist(2);
			R=varlist(3);

			// time weighting, power of to weight by
			timeK=varlist(4);

			// plant
			A=varlist(5);
			B=varlist(6);
			C=varlist(7);

		elseif (problemType=="T")
			if (nVariableInputs~=11)
				printf("varlist length : %d",nVariableInputs);
				error("length of varlist wrong");
			end
			// performance index 
			P=varlist(1);
			Q=varlist(2);
			R=varlist(3);
			V=varlist(4);

			// time weighting, power of to weight by
			timeK=varlist(5);

			// plant
			A=varlist(6);
			B=varlist(7);
			C=varlist(8);

			// routing
			G=varlist(9);
			F=varlist(10);
			H=varlist(11);
		else
			printf("problemType: %s",problemType);
			error("unknown problem type");
		end

		// zero gain values interprested as fixed
		[KFixed.i,KFixed.j]= find(K0==0);

		// sys info
		nX = size(A,1); nU = size(B,2); nY = size(C,1); nR = size(G,2);

		// optimize for step input on all channels
		r0=ones(nR,1);
	endfunction

	// nested cost function
	function [J,dJdK,ind] = cost(x,ind,varlist)

		// get variables
		[P,Q,R,V,A,B,C,G,F,H] = processInputs(varlist);

		// input ind (flag)
		requestShow=1;
		requestCost=2;
		requestGrad=3;
		requestCostAndGrad=4;	

		// output ind 
		interruptOptim=0;	
		evalFailed=-1;
		success=1;
	
		// initialize output
		JFail=1e10;
		dJdKFail=rand(nU,nY);
		J = JFail;
		dJdK = dJdKFail;

		// gains
		K = matrix(x,nU,nY);

		// gain fixing
		for c=1:length(KFixed.i)
			K(KFixed.i(c),KFixed.j(c)) = 0;
		end

		// controlled matrices
		Ac = A-B*K*C;
		Bc = G-B*K*F;

		if (problemType=="R")
			xBar = zeros(nX,1);
			yBar = zeros(nY,1);
			eBar = zeros(nR,1);
			X = eye(nX,nX);
		elseif (problemType=="T")
			xBar = -(Ac)^-1*Bc*r0;
			yBar = C*xBar+F*r0;
			eBar = r0 -H*xBar;
			X = xBar*xBar';
		else
			errr("unknown problem type");
		end
		
		// solve for dH/dS = 0 for Pk
		Pk(1,:,:) = P;
		for k=1:(timeK-1)
			Pk(k+1,:,:) = riccati(Ac,zeros(nX,nX),matrix(Pk(k,:,:),nX,nX),'c');
		end
		if(timeK < 1)
			Qc = Q+C'*K'*R*K*C;
		else
			Qc = factorial(timeK)*matrix(Pk(timeK,:,:),nX,nX)+Q+C'*K'*R*K*C;
		end 
		Pk(timeK+1,:,:) = riccati(Ac,zeros(nX,nX),Qc,'c'); // dH/dS
		Pk1 = matrix(Pk(timeK+1,:,:),nX,nX);
		normP = norm(Ac'*Pk1 + Pk1*Ac+Qc);

		// compute cost if requested
		if (ind==requestCost | ind==requestCostAndGrad)
			J = 1/2*trace(Pk1*X); // cost
			// check solution
			if (normP>1e-3)
				printf("\nWARNING: riccati solution failed\n");
				printf("\tnorm of ricatti for P: %f\n",normP);
				ind=evalFailed; // riccati solution failed
				J=JFail;
				dJdK=dJdKFail;
				return;
			end
			//printf("\ncost: %e\n",J);
		end

		// gradient computation requested
		if (ind==requestGrad | ind==requestCostAndGrad) 
			// solve for dH/dP = 0 for Sk
			Sk(timeK+1,:,:) = riccati(Ac',zeros(nX,nX),X,'c');
			normSk = norm(Ac*matrix(Sk(timeK+1,:,:),nX,nX)+..
				matrix(Sk(timeK+1,:,:),nX,nX)*Ac'+X);
			if (normSk>1e-3)
				printf("\nWARNING: riccati solution failed\n");
				printf("\tnorm of ricatti for Sk: %f\n",normSk);
				ind=evalFailed; // riccati solution failed
				J=JFail;
				dJdK=dJdKFail;
				return;
			end

			if (timeK>0)
				Sk(timeK,:,:) = riccati(Ac',zeros(nX,nX),..
					factorial(timeK)*matrix(Sk(timeK+1,:,:),nX,nX),'c'); // dH/dS
				// check solution
				normSk = norm(Ac*matrix(Sk(timeK,:,:),nX,nX)+..
					matrix(Sk(timeK,:,:),nX,nX)*Ac'+..
					factorial(timeK)*matrix(Sk(timeK+1,:,:),nX,nX));
				if (normSk>1e-3)
					printf("\nWARNING: riccati solution failed\n");
					printf("\tnorm of ricatti for Sk: %f\n",normSk);
					ind=evalFailed; // riccati solution failed
					J=JFail;
					dJdK=dJdKFail;
					return;
				end
			end
			if (timeK>2)
				for k=(timeK-2):0
					Sk(k+1,:,:) = riccati(Ac',zeros(nX,nX),matrix(Sk(k,:,:),nX,nX),'c'); // dH/dS
					// check solution
					normSk = norm(Ac*matrix(Sk(k+1,:,:),nX,nX)+Sk(k+1,:,:)*Ac'+..
						matrix(Sk(k,:,:),nX,nX));
					if (normS>1e-3)
						printf("\nWARNING: riccati solution failed\n");
						printf("\tnorm of ricatti for S: %f\n",normS);
						ind=evalFailed; // riccati solution failed
						J=JFail;
						dJdK=dJdKFail;
						return;
					end
				end
			end
			PkSkSum = matrix(Pk(1,:,:),nX,nX) * matrix(Sk(1,:,:),nX,nX);
			for k=1:timeK+1
				PkSkSum = PkSkSum + matrix(Pk(k,:,:),nX,nX)*matrix(Sk(k,:,:),nX,nX);
			end

			// calculate dH/dK = dJ/dK (since H=J when lyap hold, g=0) for gradient based methods
			Sk1 = matrix(Sk(timeK+1,:,:),nX,nX);
			dJdK = R*K*C*Sk1*C'-B'*PkSkSum*C'+B'*(Ac')^-1*Pk1*xBar*yBar';

			// gain gradient fixing
			for c=1:length(KFixed.i)
				dJdK(KFixed.i(c),KFixed.j(c)) = 0;
			end
			//disp("dJdK:");disp(dJdK)
			//printf("\tnorm of gradient: %e\n",norm(dJdK));
		else
			dJdK=zeros(nU,nY);
		end
		//disp("K:");disp(K)
		//halt()
		// make gradient into vector
		dJdK = matrix(dJdK,nU*nY,1);
	endfunction

// end of nested functions

	// check input matrices
	[P,Q,R,V,A,B,C,G,F,H,nX,nY,nU,nR,r0,KFixed] = processInputs(varargin);
	if(rank(obsv_mat(A,sqrt(Q))) < rank(A) & timeK==0)
		error("problem not observable, weight more elements of Q");	
		info = 1;
		return;
	elseif(rank(R) < size(B,2))
		error("you must weight all elements of R");	
		info = 2;
		return;
	elseif(max(real(spec(A-B*K0*C))) >0)
		printf("unstable initial gain.\n");	
		info = 3;
		return;
	end

	// intial optimization state
	x0 = matrix(K0,nY*nU,1);
	ind=4;
	gradopt = 1;

	// input ind (flag)
	requestShow=1;
	requestCost=2;
	requestGrad=3;
	requestCostAndGrad=4;	

 	// solve the optimization problem
	for i=1  // just using to scope and have break
		// quasi newton method
		printf("attempting solution with quasi-newton method\n");
		[fopt,xopt,gradopt] = optim(list(cost,varargin),x0,"qn");
		if (norm(gradopt) > 1e-3)
			printf("\tfailed\n");
			info = 4;
		else
			printf("\tconverged\n");
			info = 0;
			break;
		end

		// conjugate gradient method	
		printf("conjugate gradient method\n");
		[fopt,xopt,gradopt] = optim(list(cost,varargin),x0,"gc");
		if (norm(gradopt) > 1e-3)
			printf("\tfailed\n");
			info = 5;
		else
			printf("\tconverged\n");
			info = 0;
			break;
		end

		// non gradient based simplex method
		printf("non-gradient based, simplex method\n");
		[fopt,xopt,gradopt] = optim(list(NDcost,cost,requestCost,varargin),x0,"qn");
		if (norm(gradopt) > 1e-3)
			printf("\tfailed\n");
			info = 6;
		else
			printf("\tconverged\n");
			info = 0;
			break;
		end

		// if still failed, throw an error
		if (norm(gradopt) > 1e-3)
			error("linear quadratic design failed to converge")
			info = 7;
		else
			//printf("\tconverged\n");
			info = 0;
			break;
		end
	end

    K = matrix(xopt,nU,nY)
	//disp("K:"); disp(K)
endfunction
