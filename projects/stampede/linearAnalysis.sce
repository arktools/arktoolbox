mode(-1)
mtlb_close all;

// load constants file
exec constants.sce

// load scicoslab diagram to linearize the dynamics
load stampede.cos

// extract blocks
disp('extracting blocks for linearization');
dynamics=scs_m.objs(917).model.rpar;
motorLag=scs_m.objs(1061).model.rpar;

// lineriaztion of dynamics
disp('linearizing dynamics');
// vary u to find zero initial conitions
Yd = zeros(15,1)
Yd(y.V) = 2*3; // TODO why is they x 3? 1 m/s velocity
Yd(y.sog) = Yd(y.V);
[Xd,Ud,Yd,XPd] = steadycos2(dynamics,[],[],Yd,[],[1:$],[y.lat,y.lon]);
Xd=clean(Xd,1e-5);
Ud=clean(Ud,1e-5);
ugvTf = clean(ss2tf(lincos(dynamics,Xd,Ud)),1e-5);

// motor lag
motorLagTf = diag([tau_servo/(%s+tau_servo),tau_motor/(%s+tau_motor),0,0]);

sys.oltf = clean(ugvTf,1e-4)*motorLagTf;
sys.olss = minssAutoTol(tf2ss(sys.oltf),16);

// initialization
disp('beginning loop closures');
s = sys.olss;
fIndex= 1;

// disable white color plot, because you can't see it with a white background
f = gdf();
f.color_map(8,:) = [0,0,0]; // set white to black in color map so it can be seen

// close loops
sYawOpen = H.yaw_STR*s(y.yaw,u.STR);
[f,s,u,fIndex] = closeLoopWithPlots('yaw',fIndex,y.yaw,u.STR,s,y,u,H.yaw_STR,'ff');
sYawClosed = s(y.yaw,u.yaw);

sVOpen = H.V_THR*s(y.V,u.THR);
[f,s,u,fIndex] = closeLoopWithPlots('V',fIndex,y.V,u.THR,s,y,u,H.V_THR,'ff');
sVClosed = s(y.V,u.V);

// zoh time effect on 
[f,fIndex] = zohAnalysisPlot('yaw',fIndex, minss(sYawOpen), [1 4 16 64]);
[f,fIndex] = zohAnalysisPlot('V',fIndex, sVOpen, [1 4 16 64]);

// step responses
load stampedeBatch.cos
scs_m.props.tf = 15;
[f,fIndex] = stepAnalysis(s,scs_m,'yaw',fIndex,[1],'yaw, radians',y,u,r);

//load stampedeBatch.cos
scs_m.props.tf = 15;
[f,fIndex] = stepAnalysis(s,scs_m,'V',fIndex,[1/3],'V, m/s',y,u,r);

// restore default for figure properties
sdf();
