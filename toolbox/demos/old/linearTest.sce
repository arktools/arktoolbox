load easyStarDesign.dat
load linearTest.cos
scicos_simulate(scs_m,list(),%scicos_context);

lqSys=%scicos_context.levelFlight.combined;

figure(1)
title('velocity, ft/s')
plot(x.time(:),x.values(:,lqSys.I.velocity));
