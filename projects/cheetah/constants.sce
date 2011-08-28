mode(-1); // don't display this file loading

 // constants
g=9.81; // m/s^2

// trim conditions
betaAngle=0; // trim
wy=0; //trim
wz=0; //trim
wx=0; //trim
phi=0; //trim
psi=0; // trim
gammaAngle=0; // flight path angle,for level flight is zero

// aerodynamics
rho=1.225; // kg/m^3
rBlade=0.125; // metres
Cd0= 0.42; // guess
K_cd_cl=0.02; //guess
s_frame=.1; //guess in m^2
s_frame_side=.1; // guess in m^2

// airframe
m=1.25;  //kg
dm=.24; // guess in metres, motor moment arm

cmR = .08; // radius of sphere approximation for mass
cmZ = .1; // center of mass 10 cm below center of airframe
JSolidSphere = 2/5*m*cmR^2;
Jy=JSolidSphere + m*cmZ^2; // moments of inertia, kg-m^2
Jz=JSolidSphere; // guess, for now using solid sphere
Jx=JSolidSphere + m*cmZ^2;
Jxy = 0; Jyz = 0; Jxz = 0;
printf('\tinertia guess assuming solid sphere: %f kg-m^2',JSolidSphere);

// motor
KV=850 // rpm/Volts 
batVolt=11.1; //Volts
tau_motor=46.2; // from  motor pole (rad/s) source: https://dspace.ist.utl.pt/bitstream/2295/574042/1/Tese_de_Mestrado.pdf
T_max = 4.9; // max motor thrust in newtons
torque_max = 0.8*dm; // max motor thrust in newton-m
C_T = T_max / (rho*%pi*rBlade^4*(KV*2*%pi/60*batVolt)^2);
C_Q = torque_max / (rho*%pi*rBlade^4*(KV*2*%pi/60*batVolt)^2);
controlPeriodAtt = 1/200; // attitude control rate 50 Hz
controlPeriodPos = 1/50; // position control rate 50 Hz
navDelay = 1/200; // seconds of navigation delay

// trim
T_sum_trim = 900*g*m/(%pi^3*rho*batVolt^2*KV^2*rBlade^4*C_T);
u0=[T_sum_trim;0;0;0];

//hover
U = 0; V = 0; W = 0; // hover

// controllers

// position control loop
PID_POS_INTERVAL = 1/5; // 5 hz
PID_POS_P = 1 // 1, 20 comes from 0.05 gain
PID_POS_I = 0.5;
PID_POS_D = 3;
PID_POS_LIM = 3.5; //  20*10*%pi/180, 20 comes form 0.05 gain
PID_POS_AWU = 1.0; // allow integral to wind up to about 5 degrees
PID_POS_Z_P = 0.5;
PID_POS_Z_I = 0.1;
PID_POS_Z_D = 0.5;
PID_POS_Z_LIM = 0.4; // 40 % throttle deviation from trim contribution to motors, max
PID_POS_Z_AWU = 0.2; // allows 20% throttle trim adjustment
VEL_OFFSET_X = 0;
VEL_OFFSET_Y = 0;

// attitude control loop
PID_ATT_INTERVAL = 1/20; // 20 hz
PID_ATT_P= 25;
PID_ATT_I= 0;
PID_ATT_D= 25;
PID_ATT_LIM= 100; // max motor contribution 100/255
PID_ATT_AWU= 0;
PID_YAWPOS_P= 1;
PID_YAWPOS_I= 0;
PID_YAWPOS_D= 0;
PID_YAWPOS_LIM= 0.5; // 0.5 rad/s  max
PID_YAWPOS_AWU= 0;
PID_YAWSPEED_P= 255;
PID_YAWSPEED_I= 0;
PID_YAWSPEED_D= 0;
PID_YAWSPEED_LIM= 20; // about 10% of the motors
PID_YAWSPEED_AWU= 0.1; // rad/s windup guard
ATT_OFFSET_X =0;
ATT_OFFSET_Y =0;
ATT_OFFSET_Z = -0.080;

// mixing
MIX_REMOTE_WEIGHT = 1;
MIX_POSITION_WEIGHT =1;
MIX_POSITION_Z_WEIGHT = 1;
MIX_POSITION_YAW_WEIGHT = 1;
MIX_OFFSET_WEIGHT =1;

// waypoint
POSITION_SETPOINT_X = 0;
POSITION_SETPOINT_Y = 0;
POSITION_SETPOINT_Z = 0;
POSITION_SETPOINT_YAW = 0.0;

THRUST_HOVER_OFFSET = 150; // this is really 160 - 10 since the controller adds 10 when mapping the thrust

// linear approximations of controllers
H.pitch_FB = pidCont(PID_ATT_P,PID_ATT_I,PID_ATT_D);
H.roll_LR = pidCont(PID_ATT_P,PID_ATT_I,PID_ATT_D);
H.yawRate_LRFB = pidCont(PID_YAWSPEED_P,PID_YAWSPEED_I,PID_YAWSPEED_D);
H.yaw_yawRate = pidCont(PID_YAWPOS_P,PID_YAWPOS_I,PID_YAWPOS_D);
H.pN_pitch = -10/(%s+10)*0.05*pidCont(PID_POS_P,PID_POS_I,PID_POS_D);
H.pE_roll = 10/(%s+10)*0.05*pidCont(PID_POS_P,PID_POS_I,PID_POS_D);
H.pD_SUM = -(255-10)*pidCont(PID_POS_Z_P,PID_POS_Z_I,PID_POS_Z_D);
// scale factor from thrust adjustment block

x0 = [
U; // U
W; // W
0; // theta
wy; // wy
V; // V
0; // phi
wx; // wx
psi; // psi
wz]; //wz

r = createIndex(['pN','pE','pD','yaw']);
m = createIndex(['Vfwd','psi','h','Vside']);
x = createIndex(['U','W','pitch','pitchRate','V','roll','rollRate','yaw',..
	'yawRate','vN','vE','vD','pN','pE','pD']);
u = createIndex(['SUM','FB','LR','LRFB']);
y = x;

