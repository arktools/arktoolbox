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
rBlade=0.127; // metres
Cd0= 0.42; // guess
K_cd_cl=0.02; //guess
s_frame=0.1; //guess in m^2
s_frame_side=0.1; // guess in m^2

// airframe
m=1.02;  //kg
dm=0.25; // guess in metres, motor moment arm

cmR = 0.08; // radius of sphere approximation for mass
cmZ = 0.02; // center of mass 10 cm below center of airframe
JSolidSphere = 2/5*m*cmR^2;
Jy=JSolidSphere + m*cmZ^2; // moments of inertia, kg-m^2
Jz=JSolidSphere; // guess, for now using solid sphere
Jx=JSolidSphere + m*cmZ^2;
Jxy = 0; Jyz = 0; Jxz = 0;
printf("\tinertia guess assuming solid sphere: %f kg-m^2",JSolidSphere);

// motor
KV=760 // rpm/Volts 
batVolt=14.8; //Volts
tau_motor=36.95991; // from  motor pole (rad/s) source: https://dspace.ist.utl.pt/bitstream/2295/574042/1/Tese_de_Mestrado.pdf
T_max = 6.5; // max motor thrust in newtons
torque_max = 1*dm; // max motor thrust in newton-m
C_T = T_max / (rho*%pi*rBlade^4*(KV*2*%pi/60*batVolt)^2);
C_Q = torque_max / (rho*%pi*rBlade^4*(KV*2*%pi/60*batVolt)^2);
controlPeriodAtt = 1/20; // attitude control rate 20 Hz
controlPeriodPos = 1/5; // position control rate 5 Hz
navDelay = 0.100 // seconds of navigation delay

// trim
T_sum_trim = 900*g*m/(%pi^3*rho*batVolt^2*KV^2*rBlade^4*C_T);
u0=[T_sum_trim;0;0;0];

//hover
U = 0; V = 0; W = 0; // hover

// controllers

//motor parameters
MOTOR_MAX = 1;
MOTOR_MIN = 0.1;

// position control loop
PID_POS_INTERVAL = 1/5; // 5 hz
PID_POS_P =0.02;
PID_POS_I =0;
PID_POS_D =0.1;
PID_POS_LIM =0.1; // about 5 deg
PID_POS_AWU =0.0; // about 5 deg
PID_POS_Z_P =0.5;
PID_POS_Z_I =0.2;
PID_POS_Z_D =0.5;
PID_POS_Z_LIM =0.5;
PID_POS_Z_AWU =0.1;
VEL_OFFSET_X =0.0;
VEL_OFFSET_Y =0.0;

// attitude control loop
PID_ATT_INTERVAL = 1/20; // 20 hz
PID_ATT_P=.1;
PID_ATT_I=0.0;
PID_ATT_D=0.1;
PID_ATT_LIM=0.1; // 10 % motors
PID_ATT_AWU=0.0;
PID_YAWPOS_P=1;
PID_YAWPOS_I=0.1;
PID_YAWPOS_D=0;
PID_YAWPOS_LIM=1; // 1 rad/s
PID_YAWPOS_AWU=1; // 1 rad/s
PID_YAWSPEED_P=1;
PID_YAWSPEED_I=0;
PID_YAWSPEED_D=0.5;
PID_YAWSPEED_LIM=0.1; // 10 % motors
PID_YAWSPEED_AWU=0.0;
ATT_OFFSET_X =0.0;
ATT_OFFSET_Y =0.0;
ATT_OFFSET_Z =0.0;

// mixing
MIX_REMOTE_WEIGHT = 1;
MIX_POSITION_WEIGHT =1;
MIX_POSITION_Z_WEIGHT =1;
MIX_POSITION_YAW_WEIGHT = 1;
MIX_OFFSET_WEIGHT =0;

// waypoint
POSITION_SETPOINT_X = 0;
POSITION_SETPOINT_Y = 0;
POSITION_SETPOINT_Z = 0;
POSITION_SETPOINT_YAW = 0.0;

THRUST_HOVER_OFFSET = 0.5;

// zero order hold pade approximation
function sys = pade(controlPeriod)
	sys = (1-%s*controlPeriod/6)/(1 + %s*controlPeriod/3);
endfunction

// continuous pid controller model
function sys = pidCont(kP,kI,kD,controlPeriod)
	sys = pade(controlPeriod)*syslin('c',kP+kI/%s+%s*kD);
endfunction

// controllers
H.pitch_FB = pidCont(PID_ATT_P,PID_ATT_I,PID_ATT_D,PID_ATT_INTERVAL);
H.roll_LR = pidCont(PID_ATT_P,PID_ATT_I,PID_ATT_D,PID_ATT_INTERVAL);
H.yawRate_LRFB = pidCont(PID_YAWSPEED_P,PID_YAWSPEED_I,PID_YAWSPEED_D,PID_ATT_INTERVAL);
H.yaw_yawRate = pidCont(PID_YAWPOS_P,PID_YAWPOS_I,PID_YAWPOS_D,PID_ATT_INTERVAL);
H.pN_pitch = pidCont(PID_POS_P,PID_POS_I,PID_POS_D,PID_POS_INTERVAL);
H.pE_roll = pidCont(PID_POS_P,PID_POS_I,PID_POS_D,PID_POS_INTERVAL);
H.pD_SUM = (%s+2)/2*pidCont(PID_POS_Z_P,PID_POS_Z_I,PID_POS_Z_D,PID_POS_INTERVAL);

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

r = createIndex(["pN","pE","pD","yaw"]);
m = createIndex(["Vfwd","psi","h","Vside"]);
x = createIndex(["U","W","pitch","pitchRate","V","roll","rollRate","yaw",..
	"yawRate","vN","vE","vD","pN","pE","pD"]);
u = createIndex(["SUM","FB","LR","LRFB"]);
ch = createIndex(["mode","left","right","front","back"]);
xHil = [x.V,x.roll,x.pitch,x.yaw,x.rollRate,x.pitchRate,x.yawRate,x.yaw,x.V,x.pN,x.pE,x.pD];
y = x;

