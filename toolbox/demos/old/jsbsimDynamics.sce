clc;
mode(-1)
printf('\nLoading Model\n')
%scicos_context=[];
load('autopilotHybrid.cos')
airframeBlock=scs_m.objs(16).model.rpar;
actuatorBlock=scs_m.objs(2).model.rpar;
printf('\tModel Loaded\n')

// indices
info.x=defineIndex(["velocity";"alpha";"theta";"q";"rpm";..
	"beta";"phi";"p";"r";"alt";"psi";"longitude";"latitude";..
	"aileronPos";"elevatorPos";"rudderPos";"throttlePos"]);

// indices for output
info.y=defineIndex(["velocity";"alpha";"theta";"q";"rpm";..
	"beta";"phi";"p";"r";"alt";"psi";"longitude";"latitude";..
	"aileronPos";"elevatorPos";"rudderPos";"throttlePos"]);
	//"accelX";"accelY";"accelZ";"gyroX";"gyroY";"gyroZ";..
	//"absPressure";"diffPressure"])

// indices for input
info.u=defineIndex(["throttleCmd";"elevatorCmd";"aileronCmd";"rudderCmd"]);

// norminal condition
//XN=zeros(11,1); UN=zeros(4,1);
//XN(info.x.velocity)=80; // ft/s
//XN(info.x.altitude)=1000; // ft ASL
//XN(info.x.heading)=90*%pi/180; // rad, minimize coriolis
optimOptions=list(1e-3,0,'nd',100,100);
IndyN=[1:$];
XN=..
[   4.5000018902e+01;
    2.9629377874e-02;
    2.9629377874e-02;
   -2.1501294455e-06;
    1.0383499871e+04;
   -1.4925937478e-02;
    1.1860194078e-16;
   -3.2080994023e-08;
   -9.5081815185e-10;
    1.0000000000e+03;
    1.5707963268e+00;
    0.0000000000e+00;
    0.0000000000e+00];
UN=..
[   5.2900729828e-01;
    1.8982571149e-01;
   -4.1623929959e-01;
   -2.5962909343e-02];
   
// state costs
QN=diag(13);

// input weighting
RNdiag(info.u.elevatorCmd)=1;
RNdiag(info.u.rudderCmd)=1;
RNdiag(info.u.throttleCmd)=1000;
RN=500*diag(RNdiag);

// level flight
X=XN; U=UN; Q=QN; R=RN;
X(info.x.rpm)=20000; //initialize rpm to sane value
U(info.u.throttleCmd)=1;
Indu=[info.u.elevatorCmd,info.u.rudderCmd,info.u.throttleCmd];
Indx=[info.x.alpha,info.x.beta,info.x.theta];
Indxp=[];
levelFlight=flightModeDesign('Level Flight',airframeBlock,..
	actuatorBlock,X,U,[],Indx,Indu,IndyN,..
	Indxp,info,Q,R,optimOptions);
if (~levelFlight.success) return; end;

// right turn
//X=levelFlight.airframe.trim.X; U=levelFlight.airframe.trim.U; Q=QN; R=RN; 
//X(info.x.roll)=15*%pi/180;
//X(info.x.yawRate)=10*%pi/180;
//Indx=[info.x.velocity,info.x.alpha,info.x.roll,info.x.pitch,info.x.rpm];
//Indu=[info.u.elevatorCmd,info.u.rudderCmd,info.u.throttleCmd];
//Indxp=[info.x.heading];
//rightTurn=flightModeDesign('Right Turn',airframeBlock,..
//	actuatorBlock,X,U,[],Indx,Indu,IndyN,..
//	Indxp,info,Q,R,optimOptions);
//if (~rightTurn.success) return; end;

// left turn
//X=levelFlight.airframe.trim.X; U=levelFlight.airframe.trim.U; Q=QN; R=RN; 
//X(info.x.roll)=-15.5*%pi/180;
//X(info.x.yawRate)=-10*%pi/180;
//Indx=[info.x.velocity,info.x.alpha,info.x.roll,info.x.pitch,info.x.rpm];
//Indu=[info.u.elevatorCmd,info.u.rudderCmd,info.u.throttleCmd];
//Indxp=[info.x.heading];
//leftTurn=flightModeDesign('Left Turn',airframeBlock,..
//	actuatorBlock,X,U,[],Indx,Indu,IndyN,..
//	Indxp,info,Q,R,optimOptions);

// load into scicos
%scicos_context.levelFlight=levelFlight;
//%scicos_context.rightTurn=rightTurn;
//%scicos_context.leftTurn=leftTurn;

disp('Done');
return;
