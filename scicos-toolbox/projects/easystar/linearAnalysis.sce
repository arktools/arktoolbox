mode(-1)
mtlb_close all

// load constants file
exec constants.sce;

// load scicoslab diagram to linearize the dynamics
load easystar.cos

// extract blocks
disp('extracting blocks for linearization');
//dynamics=scs_m.objs(1).model.rpar;
actuators=scs_m.objs(46).model.rpar;

// lineriaztion of dynamics
disp('linearizing dynamics');
// vary u to find zero initial conitions
//[Xd,Ud,Yd,XPd] = steadycos2(dynamics,[],[],[],[],[1:$],[],[]);
//Xd=clean(Xd,1e-5);
//Ud=clean(Ud,1e-5);
//easyStarTf = clean(ss2tf(lincos(dynamics,Xd,Ud)),1e-5);
easyStarTf = sys;
Xd = x0;
Ud = u0;

// motor lag block
disp('linearizing actuators block');
actuatorsTf = clean(ss2tf(lincos(actuators,zeros(4,1),Ud)),1e-5);

// find complete dynamics transfer function
disp('finding dynamics transfer function');
clear sys;
sys.olss = easyStarTf*actuatorsTf;

// initialization
disp('beginning loop closures');
s = sys.olss
fIndex= 1;

// disable white color plot, because you can't see it with a white background
f = gdf();
f.color_map(8,:) = [0,0,0]; // set white to black in color map so it can be seen

// attitude loops
lowPass = 20/(%s+20);
washOut = %s/(%s+1);

[f,s,u,fIndex] = closeLoopWithPlots('r',fIndex,y.r,u.rudder,s,y,u,..
	-washOut,'fb');

// example of command to graphicaly set gain using root locus
// k=-1/real(horner(ss2tf(s(y.r,u.rudder)),[1,%i]*locate(1)))

//[f,s,u,fIndex] = closeLoopWithPlots('phi',fIndex,y.phi,u.rudder,s,y,u,..
	//-(0.001+0/%s+0*%s*lowPass),'ff');

//[f,s,u,fIndex] = closeLoopWithPlots('vt',fIndex,y.vt,u.elevator,s,y,u,..
	//(0.1+0/%s + 0.0*%s*lowPass),'ff');

//[f,s,u,fIndex] = closeLoopWithPlots('alt',fIndex,y.alt,u.throttle,s,y,u,..
	//(0.01 + 0/%s + 0.0*%s*lowPass),'ff');

//[f,s,u,fIndex] = closeLoopWithPlots('psi',fIndex,y.psi,u.phi,s,y,u,..
	//(0.5+ 0/%s + 1*%s*lowPass),'ff');





// restore default for figure properties
sdf();
