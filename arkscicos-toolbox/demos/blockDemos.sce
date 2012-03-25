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
],'arkscicos demos');
if (n==1)
	scicos(arkscicosPath+'demos/block/JSBSimBackside.cos');
elseif (n==2)
	scicos(arkscicosPath+'demos/block/JSBSimTrim.cos');
elseif (n==3)
	scicos(arkscicosPath+'demos/block/JSBSimTrimF16.cos');
elseif (n==4)
	scicos(arkscicosPath+'demos/block/JSBSimMavLinkHilState.cos');
elseif (n==5)
	scicos(arkscicosPath+'demos/block/JSBSimMavLinkHilSensor.cos');
elseif (n==6)
	scicos(arkscicosPath+'demos/block/JSBSimBacksideNav.cos');
elseif (n==7)
	scicos(arkscicosPath+'demos/block/UgvBackside.cos');
elseif (n==8)
	scicos(arkscicosPath+'demos/block/quadrotor.cos');
elseif (n==9)
	scicos(arkscicosPath+'demos/block/UgvMavlinkHilSensor.cos');
elseif (n==10)
	scicos(arkscicosPath+'demos/block/UgvMavlinkHilState.cos');
elseif (n==11)
	scicos(arkscicosPath+'demos/block/quadrotorHil.cos');
elseif (n==12)
	scicos(arkscicosPath+'demos/block/sailboat.cos');
elseif (n==13)
	scicos(arkscicosPath+'demos/block/PidDLP.cos');
elseif (n==14)
	scicos(arkscicosPath+'demos/block/PidDFB.cos');
else
	disp('unknown demo');
end
