n=x_choose([
'EasyStar Backside Autopilot Design';
'EasyStar Trim';
'EasyStar Hardware in the Loop (Sensor Level)';
'EasyStar Hardware in the Loop (State Level)';
'EasyStar GPS/INS Extended Kalman Filter based Navigation';
'Unmanned Ground Vehicle Autopilot Design';
'Quadrotor Control Demos';
//'Unmanned Ground Vehicle Hardware in the Loop (Sensor Level)';
//'Unmanned Ground Vehicle Hardware in the Loop (State Level)';
],'mavsim demos')

if (n==1)
	scicos(mavsimPath+'demos/block/JSBSimBackside.cos')
elseif (n==2)
	scicos(mavsimPath+'demos/block/JSBSimTrim.cos')
elseif (n==3)
	scicos(mavsimPath+'demos/block/JSBSimMavLinkHilState.cos')
elseif (n==4)
	scicos(mavsimPath+'demos/block/JSBSimMavLinkHilSensor.cos')
elseif (n==5)
	scicos(mavsimPath+'demos/block/JSBSimBacksideNav.cos')
elseif (n==6)
	scicos(mavsimPath+'demos/block/UgvBackside.cos')
elseif (n==7)
	scicos(mavsimPath+'demos/block/quadrotor.cos')
elseif (n==8)
	scicos(mavsimPath+'demos/block/UgvMavlinkHilSensor.cos')
elseif (n==9)
	scicos(mavsimPath+'demos/block/UgvMavlinkHilState.cos')
else
	disp('unknown demo')
end
