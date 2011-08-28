mode(-1)

// load constants file
exec constants.sce

// load scicoslab diagram to linearize the dynamics
load cheetah.cos

// extract blocks
disp('extracting blocks for linearization');
dynamics=scs_m.objs(1).model.rpar;
controller=scs_m.objs(299).model.rpar;
motorLag=scs_m.objs(96).model.rpar;
motorMix=scs_m.objs(209).model.rpar;
navigation=scs_m.objs(390).model.rpar;

// lineriaztion of dynamics
disp('linearizing dynamics');
// vary u to find zero initial conitions
[Xd,Ud,Yd,XPd] = steadycos2(dynamics,[],[],[],[],[1:$],[],[]);
Xd=clean(Xd,1e-5);
Ud=clean(Ud,1e-5);
quadTf = clean(ss2tf(lincos(dynamics,Xd,Ud)),1e-5);

// motor mix block
disp('linearizing motor mix block');
motorMixTf = clean(ss2tf(lincos(motorMix,[],[Ud(1)*255;0;0;0])),1e-5);

// motor lag block
disp('linearizing motor lag block');
motorLagTf = clean(ss2tf(lincos(motorLag,zeros(4,1),Ud)),1e-5);

// find complete dynamics transfer function
disp('finding dynamics transfer function');
sys.oltf = clean(quadTf*motorLagTf*motorMixTf,1e-4);
sys.olss = minssAutoTol(tf2ss(sys.oltf),16);

// initialization
disp('beginning loop closures');
s = sys.olss*diag(zohPade(ones(1,4)/PID_ATT_INTERVAL));
fIndex= 1;

// disable white color plot, because you can't see it with a white background
f = gdf();
f.color_map(8,:) = [0,0,0]; // set white to black in color map so it can be seen

// attitude loops
[f,s,u,fIndex] = closeLoopWithPlots('yawRate',fIndex,y.yawRate,u.LRFB,s,y,u,H.yawRate_LRFB,'ff');
[f,s,u,fIndex] = closeLoopWithPlots('roll',fIndex,y.roll,u.LR,s,y,u,H.roll_LR,'ff');
[f,s,u,fIndex] = closeLoopWithPlots('pitch',fIndex,y.pitch,u.FB,s,y,u,H.pitch_FB,'ff');
[f,s,u,fIndex] = closeLoopWithPlots('yaw',fIndex,y.yaw,u.yawRate,s,y,u,H.yaw_yawRate,'ff');

// position loops
// we can tie in pitch and roll directly since for trim we are aligned with
// North/ East frame at the linearization point
sPNOpen = H.pN_pitch*s(y.pN,u.pitch);
[f,s,u,fIndex] = closeLoopWithPlots('pN',fIndex,y.pN,u.pitch,s,y,u,H.pN_pitch,'ff');
[f,s,u,fIndex] = closeLoopWithPlots('pE',fIndex,y.pE,u.roll,s,y,u,H.pE_roll,'ff');
sPDOpen = H.pD_SUM*s(y.pD,u.SUM);
[f,s,u,fIndex] = closeLoopWithPlots('pD',fIndex,y.pD,u.SUM,s,y,u,H.pD_SUM,'ff');

// restore default for figure properties
sdf();

// zoh time effect on pN closed loop
[f,fIndex] = zohAnalysisPlot('pN',fIndex, sPNOpen, [1, 4, 16, 64, 256]);
[f,fIndex] = zohAnalysisPlot('pD',fIndex, sPDOpen, [1, 4, 16, 64, 256]);

// step responses
load cheetahBatch.cos

// manual input set to zero
mSignal = struct();
mSignal.time = 0;
mSignal.values = zeros(1,4);

// solver settings
scs_m.props.tf = 15;

// position step responses
[f,fIndex] = stepAnalysis(s,scs_m,'pN',fIndex,[0.1 1],'pN, meters',y,u,r);
[f,fIndex] = stepAnalysis(s,scs_m,'pE',fIndex,[0.1 1],'pE, meters',y,u,r);
[f,fIndex] = stepAnalysis(s,scs_m,'pD',fIndex,[0.1 1],'pD, meters',y,u,r);
