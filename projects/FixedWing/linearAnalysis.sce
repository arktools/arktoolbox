mode(-1)

// load constants file
exec easystar-datcom_lin.sce;                                                                                      //Changed to the file i needed (basically this are the Context definitions)

// load scicoslab diagram to linearize the dynamics
load JSBSimBackside.cos;                                                                                        //Changed, loads the Backsidecontroller

function tf = ss2cleanTf(ss)
	tf = clean(ss2tf(ss));
endfunction

// open loop statistics
function openLoopAnalysis(sys)
	if(typeof(sys)=='state-space') sys = ss2cleanTf(sys); end
	sse=1/(horner(sys,1e-10));                                                                           //This stuff just computes the steady state error 1/G(0) and the crossover frequency with bw(sys,0)
	if (sse>1e6) sse=%inf; end
    printf('\t\tgcf=%8.2f Hz\t\tsse=%8.2f\n',bw(tf2ss(sys),0),sse);
endfunction

// close a loop
function [sysOut,uOut] = closeLoop2(yi,ui,sys,y,u,H)
	printf('\tclosing loop: %s\n',y.str(yi)+'->'+u.str(ui));
	openLoopAnalysis(H*sys(yi,ui));
	sysOut = unityFeedback2(yi,ui,sys,H);
	uOut = createIndex(y.str(yi),u);
	[eVect,eVal] = spec(abcd(sysOut));
	eVal = diag(eVal);
	unstablePoles=find(real(eVal)>0);
	printf('\t\tunstable modes:\n');
	for i=1:size(unstablePoles,2)
		[junk,k]=sort(eVect(:,unstablePoles(i)));
		j=0; // number of valid states found
		m=1; // index 
		printf('\t\t\t');
		while 1
			if (k(m)<=size(y.str,1))		
				j = j +1;
				printf('%9s\t',y.str(k(m)));
			end
			if (j>2)
				printf('\t%8.3f + %8.3f j\n',..
					real(eVal(unstablePoles(i))),..
					imag(eVal(unstablePoles(i))));
				break;
			else
				m = m +1;
			end;
		end
	end
	poles=size(abcd(sys),1);
	printf('\t\tclbw=%f\tunstable poles=%d/%d\n',..
		bw(ss2cleanTf(sysOut),3),size(unstablePoles,2),size(abcd(sysOut),1));
endfunction


// extract blocks
  disp('extracting blocks for linearization');
dynamics=scs_m.objs(796).model.rpar;                                                                  //JSBSimComm block number 364
//controller=scs_m.objs(424).model.rpar;                                                              //Backside Controller number 424



// linerization of dynamics
disp('linearizing dynamics');

// vary u to find zero initial conitions, in my case finding the equ point of the dynamics
//[X,U,Y,XP]=steadycos2(dynamics,X_0,[],[],[11,12,13],[1:$],[],[])                                       //Does the same as the steadycos command (look it up!) only with non gradient methods. X,U,Y are at beginning all at 0. And only U can vary (makes no sense, look up the functionality of steadycos2)
//X,U,Y,XP:Equilibrium state.  X   U  Y   indx      indu  indy indxp
//The steadycos line does take very long to compute. 

PlaneSS2 = lincos(dynamics, x0, u0);
//PlaneTf2 = ss2tf(PlaneSS2);
PlaneSS=sys;                                                                                   //Linearizes the Plane dynamics
PlaneTf=tfm;

disp('done')
disp('The Linearized System has the Size: ')
disp(size(PlaneTf))

//Throttle to altitude
f=scf(1)
f.figure_position = [0 0]
f.figure_name='Throttle -> Altitude'
bode(PlaneTf(5,1))

//Elevator to Velocity
f=scf(2)
f.figure_position = [800 0]
f.figure_name='Elevator -> Velocity'
bode(PlaneTf(1,3))

//Rudder to Rollspeed
f=scf(3)
f.figure_position = [0 600]
f.figure_name='Rudder -> Rollspeed (p)'
bode(PlaneTf(7,4))

//Rudder to Yawspeed
f.figure_position = [800 600]
f=scf(4)
f.figure_name='Rudder -> Yawspeed (r)'
bode(PlaneTf(10,4))




//bode(PlaneTf(1,1));                                                                             //Up till here it is the general approach, however i am unable up to this point to linearize the JSBSimComm block. Another unsolved problem is how i can linearize only some of the inputs to outputs.

 //motor mix block
//disp('linearizing motor mix block');
//motorMixTf = clean(ss2tf(lincos(motorMix,[],[Ud(1)*255;0;0;0])),1e-5);
//
// motor lag block
//disp('linearizing motor lag block');
//motorLagTf = clean(ss2tf(lincos(motorLag,zeros(4,1),Ud)),1e-5);
//
// find complete dynamics transfer function
//disp('finding dynamics transfer function');
//sys.oltf = clean(quadTf*motorLagTf*motorMixTf,1e-4);
//sys.olss = minssAutoTol(tf2ss(sys.oltf),16);                                                            //For first, i dont need all this here.
//
// attitude loops
//disp('beginning loop closures');
//s = sys.olss;
//s0 = ss2tf(s);
//[s,u] = closeLoop2(y.pD,u.SUM,s,y,u,H.pD_SUM);
//s1 = ss2tf(s);
//[s,u] = closeLoop2(y.yawRate,u.LRFB,s,y,u,H.yawRate_LRFB);
//s2 = ss2tf(s);
//[s,u] = closeLoop2(y.roll,u.LR,s,y,u,H.roll_LR);
//s3 = ss2tf(s);
//[s,u] = closeLoop2(y.pitch,u.FB,s,y,u,H.pitch_FB);
//s4 = ss2tf(s);
//[s,u] = closeLoop2(y.yaw,u.yawRate,s,y,u,H.yaw_yawRate);
//s5 = s;
//
//sPitch = s4(y.pitch,u.pitch);

// position loops
// we can tie in pitch and roll directly since for trim we are aligned with
// North/ East frame

//[s,u] = closeLoop2(y.pN,u.pitch,s,y,u,H.pN_pitch);
//s6 = s;
//[s,u] = closeLoop2(y.pE,u.roll,s,y,u,H.pE_roll);
//s7 = s;
//
//sPN = s7(y.pN,u.pN);
//sPNOpen = s5(y.pN,u.pitch)*H.pN_pitch;

//disp('beginning plotting');

// position north, and pitch
//f=scf(1); clf(1);
//f.figure_size=[600,600];
//set_posfig_dim(f.figure_size(1),f.figure_size(2));
//bode([sPitch*pade(PID_ATT_INTERVAL);sPN*pade(PID_POS_INTERVAL)],..
	//0.01,99,.01,["pitch";"position north"])
//xs2eps(1,'pN_pitch');

// zoh time effect on pN closed loop
//f=scf(2); clf(2);
//f.figure_size=[600,600];
//set_posfig_dim(f.figure_size(1),f.figure_size(2));
//bode([sPN*pade(4);sPN*pade(2);sPN*pade(1);sPN*pade(1/2);..
	//sPN*pade(1/4);sPN*pade(1/16)],0.01,99,.01,..
	//["1/4 Hz";"1/2 Hz";"1 Hz";"2 Hz";"4 Hz";"16 Hz"])
//xs2eps(2,'pN_closed_zoh');

// zoh time effect on pN open loop
//f=scf(3); clf(3);
//f.figure_size=[600,600];
//set_posfig_dim(f.figure_size(1),f.figure_size(2));
//bode([sPNOpen*pade(4);sPNOpen*pade(2);sPNOpen*pade(1);sPNOpen*pade(1/2);..
	//sPNOpen*pade(1/4);sPNOpen*pade(1/16)],0.01,99,.01,..
	//["1/4 Hz";"1/2 Hz";"1 Hz";"2 Hz";"4 Hz";"16 Hz"])
//xs2eps(3,'pN_open_zoh');
