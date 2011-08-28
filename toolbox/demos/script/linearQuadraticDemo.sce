clc; clear; lines(0);
mode(-1)

// depends on lqof.sci of the mavsim toolbox

// F-16 lateral regulator
// example from pg. 414

A = [-0.3220,0.0640,0.0364,-0.9917,0.0003,0.0008,0;
     0,0,1,0.0037,0,0,0;
    -30.6492,0,-3.6784,0.6646,-0.7333,0.1315,0;
     8.5396,0,-0.0254,-0.4764,-0.0319,-0.0620,0;
    0,0,0,0,-20.2,0,0;
    0,0,0,0,0,-20.2,0;
    0,0,0,57.2958,0,0,-1];
B = [0,0;0,0;0,0;0,0;20.2,0;0,20.2;0,0];
C = [0,0,0,57.2958,0,0,-1;
     0,0,57.2958,0,0,0,0;
     57.2958,0,0,0,0,0,0;
     0,57.2958,0,0,0,0,0];
nX = size(A,1); nU = size(B,2); nY = size(C,1);
nR = 2;
sys = syslin('c',A,B,C);
P = 0.001*eye(nX,nX);
Q = diag([50,100,100,50,0,0,1]);
R = 0.1*eye(nU,nU);
V = 0*eye(nX,nX); // steady state error weighting
G = zeros(nX,nR);
F = eye(nY,nR);
timeK = 2;
// answer you should get from the book, pg. 416
KBook = [-.56,-.44,0.11,-0.35;-1.19,-.21,-0.44,0.26];
K=[];
gradopt=[];
info=[];
loopCount=0;

while(1)
	K0 = 1*(rand(nU,nY)-.5);
	K0(1,1) = 0; K0(1,3) = 0;
	K0(2,2) = 0; K0(2,4) = 0;
	[K,gradopt,info] = lqof("R",K0,P,Q,R,timeK,A,B,C);
	if (info==0)
		printf("\ndesign completed successfully\n");
		break;
	elseif (loopCount < 100)
		printf("trying new random gain as initial guess\n");
		loopCount = loopCount + 1;
	else
		printf("design failed\n");
		break;
	end
end

sysC = syslin('c',A-B*K*C,B,C);
sysCBook = syslin('c',A-B*KBook*C,B,C);
t = linspace(0,10,1000); u = zeros(1,size(t,2));
x0 = zeros(7,1); x0(1) = 1.0*%pi/180;

disp("eigen values of open loop"); disp(spec(A))
disp("eigen values of closed loop design from book"); disp(spec(sysCBook.A))
disp("eigen values of closed loop design new"); disp(spec(sysC.A))
disp(K,"K")

scf(1); clf();
subplot(3,2,1);
title("linear quadratic design");
[sim.y,sim.x] = csim(u,t,sysC(:,1),x0);
plot2d(t,sim.y',leg="r@p@beta@phi");
subplot(3,2,2);
title("design input");
plot2d(t,(K*sim.y)',leg="aileron@elevator");

subplot(3,2,3);
title("design from book");
[sim.y,sim.x] = csim(u,t,sysCBook(:,1),x0);
plot2d(t,sim.y',leg="r@p@beta@phi");
subplot(3,2,4);
title("design book input");
plot2d(t,(KBook*sim.y)',leg="aileron@elevator");

subplot(3,2,5);
title("open loop");
[sim.y,sim.x] = csim(u,t,sys(:,1),x0);
plot2d(t,sim.y',leg="r@p@beta@phi");

//Pitch-Rate Control System Using LQ Design
//Page 444
A=[-1.01887,0.90506,-0.00215,0,0;0.82225,-1.07741,-0.17555,0,0;0,0,-20.2,0,0;10,0,0,-10,0;0,-57.2958,0,0,0];
B=[0;0;20.2;0;0];
G=[0;0;0;0;1];
C=[0,0,0,57.2958,0;0,57.2958,0,0,0;0,0,0,0,1];
F=[0;0;0];
H=[0,57.2958,0,0,0];
nX = size(A,1); nU = size(B,2); nY = size(C,1);
nR = size(H,1)
sys = syslin('c',A,B,C);
P = H'*H;
Q = zeros(nX,nX); //?
R = 1*eye(nU,nU);
V = 0*eye(nX,nX); // steady state error weighting
timeK = 2;
// answer you should get from the book, pg. 416
KBook = [-0.046,-1.072,3.381];
K=[];
gradopt=[];
info=[];
loopCount=0;
while(1)
	K0 = 1*(rand(nU,nY)-.5);
	//K0(1,1) = 0; K0(1,3) = 0;
	//K0(2,2) = 0; K0(2,4) = 0;
	[K,gradopt,info] = lqof("T",K0,P,Q,R,V,timeK,A,B,C,G,F,H);
	if (info==0)
		printf("\ndesign completed successfully\n");
		break;
	elseif (loopCount < 100)
		printf("trying new random gain as initial guess\n");
		loopCount = loopCount + 1;
	else
		printf("design failed\n");
		break;
	end
end

sysC = syslin('c',A-B*K*C,B,C);
sysCBook = syslin('c',A-B*KBook*C,B,C);
t = linspace(0,10,1000);

disp("eigen values of open loop"); disp(spec(A))
disp("eigen values of closed loop design from book"); disp(spec(sysCBook.A))
disp("eigen values of closed loop design new"); disp(spec(sysC.A))
disp(K,"K")

scf(2); clf();
subplot(3,2,1);
title("linear quadratic tracker design");
[sim.y,sim.x] = csim('step',t,sysC(:,1));
plot2d(t,sim.y(2,:)',leg="r@p@beta@phi");
subplot(3,2,2);
title("design input");
plot2d(t,(K*sim.y)',leg="aileron@elevator");

subplot(3,2,3);
title("design from book");
[sim.y,sim.x] = csim('step',t,sysCBook(:,1));
plot2d(t,sim.y(2,:)',leg="r@p@beta@phi");
subplot(3,2,4);
title("design book input");
plot2d(t,(KBook*sim.y)',leg="aileron@elevator");

subplot(3,2,5);
title("open loop");
[sim.y,sim.x] = csim(u,t,sys(:,1));
plot2d(t,sim.y(2,:)',leg="r@p@beta@phi");


