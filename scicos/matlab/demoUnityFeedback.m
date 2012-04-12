% Demonstration of unity feedback
%
% Copyright 2011 James Goppert
% Released under GPL v3 License
%

clc;
disp('=============================================================')
disp('First create a model of the plant, typically through linearization.')
disp('We create a simple model here with some first order poles.')
s = tf('s');

G(1,1) = 20/s;
G(1,2) = 20/s;
G(2,1) = 20/s;
G(2,2) = 20/s^2;

disp('G: ');
G
data.G = G;

disp('=============================================================')
disp('now we create a vector of controllers')
disp('these are both simple pid controllers with')
disp('a low pass filter on the derivative feedback')
H(1,1) = 1 + 0.0/s + 1.0*s/(s+20);
H(2,2) = 1 + 0.0/s + 1.0*s/(s+20);

 % all off diagonal components must be zero for unity feedback function
for i=1:size(H,1) 
    for j=1:size(H,2)
        if (i~=j) H(i,j) = 0; end
    end
end

disp('H: ');           
H
data.H = H;

disp('=============================================================')
disp('finally we tell the function to close output 1 with input 1')
disp('and output 2 with input 2')
u = [1,2]
y = [1,2]
data.u = u;
data.y = y;
disp('=============================================================')
disp('this leaves us with the closed loop system');
disp('note the closed loop inputs are appended to the end, (1->3,2->4) ');
cltf = unityFeedback(data.G,data.H,data.u,data.y)
data.cltf = cltf;

% plotting
figure(1);
subplot(1,2,1); bode(G(1,1)*H(1,1),{0.1,100}); grid on;
subplot(1,2,2); bode(cltf(1,3),{0.1,100}); grid on;
[Gm,Pm,Wcg,Wcp] = margin(G(1,1)*H(1,1))

figure(2);
subplot(1,2,1); bode(G(2,2)*H(2,2),{0.1,100}); grid on;
subplot(1,2,2); bode(cltf(2,4),{0.1,100}); grid on;
[Gm,Pm,Wcg,Wcp] = margin(G(2,2)*H(2,2))