mode(0)
disp('updating context')

// --------------------------------------- CONSTANTS -----------------------------------------------------------------------

// constants, this is where units are set
ft2m = 0.3048;
m2ft = 1/ft2m;
Re = 6378137*m2ft; // ft
Omega = 7.292115e-5; // rad/s
g0 = 32.05; // ft/s^2
epsilon = 1e-10; // used to prevent divide by zeros in frequency

// --------------------------------------- TIMING  ----------------------------------------------------------------------------

// data collection frequency
dataFreq = 10; // Hz

// clock frequency
clockFreq = 100; //Hz

// --------------------------------------- INDICES  -----------------------------------------------------------------

x = createIndex(['vt','alpha','theta','q','beta','phi','p','psi','r','lat','lon','alt','rpm','proppitch']);
xNav = createIndex(['a','b','c','d','vn','ve','vd','lat','lon','alt']);
y = createIndex(['lat','lon','alt','cog','sog','fx','fy','fz','p','q','r','vn','ve','vd']);
u = createIndex(['thr','ail','elv','rdr']);
gBus = createIndex(['lat','lon','alt','spd']);
oBus = createIndex(['lat','lon','alt','spd','psi']);

// --------------------------------------- INITIAL STATE  ------------------------------------------------------

// load plane
exec(arkscicosPath+'/demos/data/easystar-windtunnel_lin.sce');

// no aileron
u0(u.ail) = 0; // just for visualization

// heading 180 deg
x0(x.psi)=0*%pi/180;

latLonDiff=.0002;

// start in san francisco
lon0=1e-10*%pi/180;
lat0=1e-10*%pi/180;
x0(x.lon)=lon0;
x0(x.lat)=lat0;

// initial values
alt0=x0(x.alt);
vt0=x0(x.vt);
phi = x0(x.phi);
theta = x0(x.theta);
psi = x0(x.psi);

// initial nav state
phi2= phi/2;
theta2 = theta/2;
alpha = x0(x.alpha);
psi2 = psi/2;
x0Nav(xNav.a) = cos(phi2)*cos(theta2)*cos(psi2)+sin(phi2)*sin(theta2)*sin(psi2);
x0Nav(xNav.b) = sin(phi2)*cos(theta2)*cos(psi2)-cos(phi2)*sin(theta2)*sin(psi2);
x0Nav(xNav.c) = cos(phi2)*sin(theta2)*cos(psi2)+sin(phi2)*cos(theta2)*sin(psi2);
x0Nav(xNav.d) = cos(phi2)*cos(theta2)*sin(psi2)-sin(psi2)*sin(theta2)*cos(psi2);
x0Nav(xNav.vn) = vt0*cos(theta-alpha)*cos(psi);
x0Nav(xNav.ve) = vt0*cos(theta-alpha)*sin(psi)-0.896;
x0Nav(xNav.vd) = -vt0*sin(theta-alpha);
x0Nav(xNav.lat) = lat0;
x0Nav(xNav.lon) = lon0;
x0Nav(xNav.alt) = alt0;

// initial nav state covariance
P = diag(0*ones(10,1));

// --------------------------------------- CONTROLLER ------------------------------------------------------

// servos
aileron.sign = 1;
elevator.sign = 1;
throttle.sign = 1;
rudder.sign = -1;

// lateral control system

// roll
phi_pid.kp = 0.3;
phi_pid.ki = 0;
phi_pid.kd = 0;
phi_pid.imax = 1;
phi_pid.wcut = 100;
phi_sat = 10;

// yaw rate
r_pid.kp = 0.5
r_pid.ki = 0;
r_pid.kd = 0;
r_pid.imax = 1;
r_pid.wcut = 100;

// heading
psi_pid.kp = 1;
psi_pid.ki = 0;
psi_pid.kd = 0;
psi_pid.imax = 1;
psi_pid.wcut = 100;

// longitudinal control system

// velocity
vt_pid.kp = 0.01;
vt_pid.ki = 0;
vt_pid.kd = 0;
vt_pid.imax = 1;
vt_pid.wcut = 100;

// altitude
h_pid.kp = 0.01;
h_pid.ki = 0;
h_pid.kd = 0;
h_pid.imax = 1;
h_pid.wcut = 100;

// control rate
cont.freq = 100;

// --------------------------------------- SENSORS --------------------------------------------------------------
// gps measurement
gps.freq = 10; // Hz
gps.sigLatLon= 5/Re; // rad  (5 ft, at 0 lat/ lon)
gps.sigAlt = 10; // ft
gps.sigVel = 0.3; // ft/s
gps.H =eye(6,6); 
gps.R = diag([gps.sigVel^2*ones(3,1);gps.sigLatLon^2*ones(2,1);gps.sigAlt^2]);

// mag measurement
mag.freq = 50; // Hz // can't run at same freq as gps or it won't run
mag.sigDip=  0.1*%pi/180; // inclination noise, rad
mag.sigDec = 0.1*%pi/180; // declination noise, rad
mag.processNoise = 0*%pi/180; // used to distrust mag

// imu measurement
imu.freq = 100; // Hz
imu.sigGyro=  0.005;
imu.sigAccel=  0.0082*g0;
imu.processNoiseAccel = 0.1*g0; // to account for gravity model inaccuracies
imu.processNoiseGyro = 0;
Pu = diag([(imu.processNoiseAccel+imu.sigAccel)^2*ones(3,1);(imu.processNoiseGyro+imu.sigGyro)^2*ones(3,1)]);
PuImu =  diag([(imu.processNoiseAccel+imu.sigAccel)^2*ones(3,1)]);
PuGyro = diag([(imu.processNoiseGyro+imu.sigGyro)^2*ones(3,1)]);

// --------------------------------------- GUIDANCE ----------------------------------------------------------------

// obstacle initial conditions
obst.mode = 1; // (1) Oscillating vector from aircraft (2) moving from initial condition, 
obst.vt0 = 30;
obst.psi0 = 270*%pi/180;
obst.lat0 = lat0 + latLonDiff*0.4;
obst.lon0 = lon0 + latLonDiff;
obst.alt0 = alt0;

// waypoint
dest.lat = lat0 + latLonDiff*0.6;
dest.lon = lon0 + latLonDiff*0.6;
