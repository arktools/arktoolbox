clc;
mode(-1);

// dependencies
//exec utilities.sci;
exec quadForwardFlightDesign.sci;
exec quadHoverDesign.sci;

// constants
g=9.81; // m/s^2

// trim conditions
beta=0; // trim
wy=0; //trim
wz=0; //trim
wx=0; //trim
phi=0; //trim
psi=0; // trim
gamma=0; // flight path angle,for level flight is zero

// aerodynamics
rho=1.225; // kg/m^3
rBlade=0.125; // metres
Cd0=0.42; // guess
K_cd_cl=0.02; //guess
s_frame=.1; //guess in m^2
s_frame_side=.1; // guess in m^2

// motor
KV=850 // rpm/Volts 
batVolt=11.1; //Volts
dm=.3; // guess in metres, motor moment arm
tau_motor=18; // guess, motor pole (rad/s)
T_max = 5; // max motor thrust in newtons
torque_max = 0.8*dm; // max motor thrust in newton-m
C_T = T_max / (rho*%pi*rBlade^4*(KV*2*%pi/60*batVolt)^2);
C_Q = torque_max / (rho*%pi*rBlade^4*(KV*2*%pi/60*batVolt)^2);
controlPeriod = 1/10; // controlling motors at 10 Hz

// airframe
m=1;  //kg
JSolidSphere = 2/5*m*dm^2;
Jy=JSolidSphere; // moments of inertia, kg-m^2
Jz=JSolidSphere; // guess, for now using solid sphere
Jx=JSolidSphere;
printf("\tinertia guess assuming solid sphere: %f kg-m^2",JSolidSphere);

// design controllers

// forward flight
//Vt=3; // airspeed, in m/s
//// output _ input
//Hf.wx_LR 		= 1*(%s+18)/(%s+40);
//Hf.wy_FB 		= 1*(%s+18)/(%s+40); 
//Hf.wz_LR_FB 	= 1*(%s+18)/(%s+40);
//Hf.phi_wx 		= 2.5; 		
//Hf.theta_wy 	= 2.5; 		
//Hf.psi_phi 		= 1.0; 		
//Hf.Vt_Sum 		= 0.001; 
//Hf.h_theta 		= 1.0;

//qwd = quadForwardFlightDesign(Hf);

//hover
U = 0; V = 0; W = 0; // hover
wCut = 5*2*%pi; // @ 5 Hz, cut at half the control freq for good noise atten.
lowPass = syslin('c',wCut/(%s+wCut));
lead = syslin('c',lowPass*(%s+tau_motor)/tau_motor);

Hh.wx_LR 		= 0.098*lead;
Hh.wy_FB 		= 0.098*lead;
Hh.wz_LR_FB 	= 1.35*lead; 
Hh.W_Sum 		= -0.23*lead;
Hh.phi_wx 		= 0.94;
Hh.theta_wy 	= 0.94;
Hh.psi_wz 		= 0.25;
Hh.U_theta 		= -0.025;
Hh.V_phi 		= 0.025;
Hh.h_W 			= -0.25;

qhd = quadHoverDesign(Hh);

// step responses
t = linspace(0,20); scf(1); clf(1);
subplot(2,2,1); title(qhd.y.str(qhd.y.h)+" step response");
plot(t,csim('step',t,qhd.clss(qhd.y.h,qhd.u.h))); xgrid;

subplot(2,2,2); title(qhd.y.str(qhd.y.U)+" step response");
plot(t,csim('step',t,qhd.clss(qhd.y.U,qhd.u.U))); xgrid;

subplot(2,2,3); title(qhd.y.str(qhd.y.V)+" step response");
plot(t,csim('step',t,qhd.clss(qhd.y.V,qhd.u.V))); xgrid;

subplot(2,2,4); title(qhd.y.str(qhd.y.psi)+" step response");
plot(t,csim('step',t,qhd.clss(qhd.y.psi,qhd.u.psi))); xgrid;

// bode
scf(2); clf(2);
subplot(2,2,1); bode(qhd.clss(qhd.y.h,qhd.u.h),1e-3,1,qhd.y.str(qhd.y.h));
subplot(2,2,2); bode(qhd.clss(qhd.y.U,qhd.u.U),1e-3,1,qhd.y.str(qhd.y.U));
subplot(2,2,3); bode(qhd.clss(qhd.y.V,qhd.u.V),1e-3,1,qhd.y.str(qhd.y.V));
subplot(2,2,4); bode(qhd.clss(qhd.y.psi,qhd.u.psi),1e-2,1,qhd.y.str(qhd.y.psi));
