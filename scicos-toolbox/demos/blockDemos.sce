n=x_choose([
'EasyStar Backside Autopilot Design';
'EasyStar Trim';
'F16 Trim';
'EasyStar (State Level) Hardware in the Loop';
'EasyStar (Sensor Level) Hardware in the Loop';
'EasyStar GPS/INS Extended Kalman Filter based Navigation';
'Unmanned Ground Vehicle Autopilot Design';
'Quadrotor Control Demos';
'UGV (Sensor Level) Hardware in the Loop';
'UGV (State Level) Hardware in the Loop';
'Quadrotor (State Level) Hardware in the Loop';
'Sailboat Autopilot';
'Digtal PID Controller w/ Low Pass Filter';
'Digtal PID Controller w/ Derivative Feedback';
'Joystick Demo';
],'arktoolbox demos');
if (n==1)
	scicos(arktoolboxPath+'demos/block/JSBSimBackside.cos');
elseif (n==2)
	scicos(arktoolboxPath+'demos/block/JSBSimTrim.cos');
elseif (n==3)
	scicos(arktoolboxPath+'demos/block/JSBSimTrimF16.cos');
elseif (n==4)
	scicos(arktoolboxPath+'demos/block/JSBSimMavLinkHilState.cos');
elseif (n==5)
	scicos(arktoolboxPath+'demos/block/JSBSimMavLinkHilSensor.cos');
elseif (n==6)
	scicos(arktoolboxPath+'demos/block/JSBSimBacksideNav.cos');
elseif (n==7)
	scicos(arktoolboxPath+'demos/block/UgvBackside.cos');
elseif (n==8)
	scicos(arktoolboxPath+'demos/block/quadrotor.cos');
elseif (n==9)
	scicos(arktoolboxPath+'demos/block/UgvMavlinkHilSensor.cos');
elseif (n==10)
	scicos(arktoolboxPath+'demos/block/UgvMavlinkHilState.cos');
elseif (n==11)
	scicos(arktoolboxPath+'demos/block/quadrotorHil.cos');
elseif (n==12)
	scicos(arktoolboxPath+'demos/block/sailboat.cos');
elseif (n==13)
	scicos(arktoolboxPath+'demos/block/PidDLP.cos');
elseif (n==14)
	scicos(arktoolboxPath+'demos/block/PidDFB.cos');
elseif (n==15)
	scicos(arktoolboxPath+'demos/block/joystick.cos');
else
	disp('unknown demo');
end
