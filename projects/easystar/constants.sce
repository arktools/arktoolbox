exec 'easystar-windtunnel_lin.sce';

x = createIndex(['vt','alpha','theta','q','alt','beta','phi','p','r','psi','lng','lat','rpm','propPitch']);
r = createIndex(['psi','vt','alt']);
u = createIndex(['throttle','aileron','elevator','rudder']);
y = x;
// servos
aileron.sign = 1;
elevator.sign = 1;
throttle.sign = 1;
rudder.sign = -1;

// lateral control system

// roll
phi_pid.kp = .5;
phi_pid.ki = 0;
phi_pid.kd = 0;
phi_pid.imax = 1;
phi_pid.wcut = 20;
phi_pid.dt=.01;
phi_sat = 30;

// yaw rate
r_pid.kp = 1;
r_pid.ki = 0;
r_pid.kd = 0;
r_pid.imax = 1;
r_pid.wcut = 20;
r_pid.dt=.01;

// heading
psi_pid.kp = 1;
psi_pid.ki = 0;
psi_pid.kd = 0;
psi_pid.imax = 1;
psi_pid.wcut = 20;
psi_pid.dt=.01;

// longitudinal control system

// velocity
vt_pid.kp = .05;
vt_pid.ki = 0;
vt_pid.kd = .1
vt_pid.imax = 1;
vt_pid.wcut = 20;
vt_pid.dt=.01;

// altitude
h_pid.kp = .1;
h_pid.ki = 0;
h_pid.kd = .1
h_pid.imax = 1;
h_pid.wcut = 20;
h_pid.dt=.01;
