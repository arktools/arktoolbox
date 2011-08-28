function sys = unityFeedback(G,H,u,y)
%unityFeedback Performs a unity feedback loop closure.
%   G : Plant
%   H : Controller
%   u : input vector
%   y : output vector
%
% Copyright 2011 James Goppert
% Released under GPL v3 License
%
C = zeros(length(u),size(G,1));
for (i=1:length(u)) C(i,u(i)) = 1; end;
D = zeros(size(G,2),size(y,2));for (i=1:length(y)) D(y(i),i) = 1; end;
sys=(eye(size(G,1),size(G,1))+G*D*H*C)\[G,G*D*H];
sys = minrealAutoTol(sys,order(G)+order(H));
end

