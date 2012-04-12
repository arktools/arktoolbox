disp('updating context')
lat0 = -80;
lon0=40;
alt0 = 0.2;
R = 6378100;

clockFreq=50;
cont.freq = 50;
vis.freq = 10;
epsilon=1e-10;

// no aileron
u0(1) = 0;
u0(2) = 0;
u0(3) = 0;
u0(4) = 0;

// heading 180 deg
x0(10)=0*%pi/180;

// start in san francisco
x0(11)=-122.4*%pi/180;
x0(12)=37.8*%pi/180;

throttle.sign=1
aileron.sign=1
elevator.sign=1
rudder.sign=1

// lateral control system

// roll
phi_pid.kp = .0001;
phi_pid.ki = 0;
phi_pid.kd = 0;
phi_pid.imax = 1;
phi_pid.wcut = 20;
phi_pid.dt=.01;
phi_sat = 3600000;

// yaw rate
r_pid.kp = 0;
r_pid.ki = 0;
r_pid.kd = 0;
r_pid.imax = 1;
r_pid.wcut = 20;
r_pid.dt=.01;

// heading
psi_pid.kp = 100;
psi_pid.ki = 0;
psi_pid.kd = 0;
psi_pid.imax = 1;
psi_pid.wcut = 20;
psi_pid.dt=.01;

// longitudinal control system

// velocity
vt_pid.kp = 10;
vt_pid.ki = 0;
vt_pid.kd = 0
vt_pid.imax = 1;
vt_pid.wcut = 20;
vt_pid.dt=.01;

// altitude
h_pid.kp = 0;
h_pid.ki = 0;
h_pid.kd = 0
h_pid.imax = 1;
h_pid.wcut = 20;
h_pid.dt=.01;

x = createIndex(['v','roll','pitch','yaw','P','Q','R','cog','sog','lat','lon','alt','xN','xE','xD']);
u = createIndex(['junk1','junk2','thr','str']);
