function data=flightModeDesign(flightModeName,airframeBlock,..
	actuatorBlock,X,U,Y,Indx,Indu,Indy,Indxp,info,Q,R,optimOptions)

	// Indx,Indu, Indy, indices not fixed during trim
	// Indxp indices of derivatives that need not be zero
	rad2deg=180/%pi;
	printf('\nFlight Mode: %s\n',flightModeName);

  	printf('\tTrimming Airframe\n')
	// performs better if steadycos run twice for some reason
  	[X,U,Y,XP]=steadycos2(airframeBlock,X,U,Y,Indx,Indu,Indy,Indxp,optimOptions);
  	[X,U,Y,XP]=steadycos2(airframeBlock,X,U,Y,Indx,Indu,Indy,Indxp,optimOptions);
  	XP(Indxp)=0;
	printf('\t\ttrim derivative norm: %f\n', norm(XP))
	[maxDev,maxI]=maxi(abs(XP));
	printf('\t\tlargest deviation of: %f in: %s derivative\n',..
		XP(maxI), info.x.str(maxI))
	
	printf('\t\ttrim state:\n');
	printf('\t\t\tvelocity, ft/s:\t\t%f\n', X(info.x.velocity));
	printf('\t\t\talpha, deg:\t\t%f\n', X(info.x.alpha)*rad2deg);
	printf('\t\t\tpitch, deg:\t\t%f\n', X(info.x.pitch)*rad2deg);
	printf('\t\t\tpitchRate, deg/s:\t%f\n', X(info.x.pitchRate)*rad2deg);
	printf('\t\t\taltitude, ft:\t\t%f\n', X(info.x.altitude));
	printf('\t\t\tsideSlip, deg:\t\t%f\n', X(info.x.sideSlip)*rad2deg);
	printf('\t\t\troll, deg:\t\t%f\n', X(info.x.roll)*rad2deg);
	printf('\t\t\trollRate, deg/s:\t%f\n', X(info.x.rollRate)*rad2deg);
	printf('\t\t\tyawRate, deg/s:\t\t%f\n', X(info.x.yawRate)*rad2deg);
	printf('\t\t\theading, deg:\t\t%f\n', X(info.x.heading)*rad2deg);
	printf('\t\t\trpm, rev/min:\t\t%f\n', X(info.x.rpm));
	
    printf('\t\ttrim input:\n');
    printf('\t\t\taileron, \%:\t\t%f\n', 100*U(info.u.aileronCmd));
    printf('\t\t\televator, \%:\t\t%f\n', 100*U(info.u.elevatorCmd));
    printf('\t\t\trudder, \%:\t\t%f\n', 100*U(info.u.rudderCmd));
    printf('\t\t\tthrottle, \%:\t\t%f\n', 100*U(info.u.throttleCmd));

	airframe.trim.X=X;
	airframe.trim.Y=Y;
	airframe.trim.U=U;
	airframe.trim.XP=XP;

  	if (norm(airframe.trim.XP)>.1) 
  	   disp('Airframe Trim Failed!'); 
  	   data.airframe=airframe; 
	   data.success=0;
  	   return;
	else
	   data.success=1;
	end
 
	printf('\tLinearizing Airframe\n')
	airframe.sys=lincos(airframeBlock,airframe.trim.X,airframe.trim.U);

	printf('\tTrimming Actuator\n')
	// performs better if steadycos run twice for some reason
  	[X,U,Y,XP]=steadycos2(actuatorBlock,airframe.trim.U,airframe.trim.U,..
		airframe.trim.U,[1:$],[],[],[],optimOptions);
	[X,U,Y,XP]=steadycos2(actuatorBlock,airframe.trim.U,airframe.trim.U,..
		airframe.trim.U,[1:$],[],[],[],optimOptions);
  	XP(Indxp)=0;
	printf('\t\ttrim derivative norm: %f\n', norm(XP))
	[maxDev,maxI]=maxi(abs(XP));
	printf('\t\tlargest deviation of: %f in: %s derivative\n',..
		XP(maxI), info.x.str(maxI))

	// force these to trim to correct values
	// since scicoslab doesn't trim the actuator correctly
	// not sure why this is
	// this won't work with actuators with more than one pole
	printf('\t\tNote: forcing known trim conditions for first order actuators.\n'); 
	actuator.trim.X=airframe.trim.U;
	actuator.trim.Y=airframe.trim.U;
	actuator.trim.U=airframe.trim.U;
	actuator.trim.XP=XP;

  	if (norm(actuator.trim.XP)>.1) 
  	   disp('Actuator Trim Failed!'); 
  	   data.actuator=actuator; 
	   data.success=0;
  	   return;
	else
	   data.success=1;
	end

	printf('\tLinearizing Actuator\n')
	actuator.sys=lincos(actuatorBlock,actuator.trim.U,..
		actuator.trim.U);

	// complete system
	complete.sys=airframe.sys*actuator.sys;
	complete.Q=sysdiag(Q,diag(0*ones(4,1)));
	complete.R=R;
	complete.trim.X=[airframe.trim.X;actuator.trim.X];
	complete.trim.U=airframe.trim.U;
	complete.trim.Y=[airframe.trim.Y;actuator.trim.Y];
	complete.trim.XP=[airframe.trim.XP;actuator.trim.XP];
	complete.info=info;

	printf('\tDesigning Combined Controller\n')
	combined=lqSysCreate("combined",complete,..
		[info.x.velocity,info.x.alpha,info.x.pitch,info.x.pitchRate,..
		info.x.sideSlip,info.x.roll,info.x.rollRate,info.x.yawRate,..
		info.x.elevatorPos,info.x.rudderPos,info.x.throttlePos],..
		..
		[info.u.elevatorCmd,info.u.rudderCmd,info.u.throttleCmd],..
		..
		[info.y.velocity,info.y.alpha,info.y.pitch,info.y.pitchRate,..
		info.y.sideSlip,info.y.roll,info.y.rollRate,info.y.yawRate,..
		info.y.elevatorPos,info.y.rudderPos,info.y.throttlePos]);

	printf('\tDesigning Longitudinal Controller\n')
	longitudinal=lqSysCreate("longitudinal",complete,..
		[info.x.velocity,info.x.alpha,info.x.pitch,info.x.pitchRate,..
		info.x.elevatorPos,info.x.throttlePos],..
		..
		[info.u.elevatorCmd,info.u.rudderCmd,info.u.throttleCmd],..
		..
		[info.x.velocity,info.x.alpha,info.x.pitch,info.x.pitchRate,..
		info.x.elevatorPos,info.x.throttlePos]);

	//longitudinal=lqSysCreate("longitudinal",complete,..
		//[info.x.velocity,info.x.alpha,info.x.pitch,info.x.pitchRate,..
		//info.x.elevatorPos,info.x.throttlePos],..
		//..
		//[info.y.elevatorPos,info.y.throttlePos],..
		//..
		//[info.y.velocity,info.y.alpha,info.y.pitch,info.y.pitchRate,..
		//info.y.elevatorPos,info.y.throttlePos]);

	printf('\tDesigning Lateral Controller\n')
	lateral=lqSysCreate("lateral",complete,..
		[info.x.sideSlip,info.x.roll,info.x.rollRate,info.x.yawRate,info.x.heading,..
		info.x.rudderPos],..
		[info.u.rudderCmd],..
		[info.y.sideSlip,info.y.roll,info.y.rollRate,info.y.yawRate,info.y.heading,..
		info.y.rudderPos]);

	// send controller to scicos
	data.name=flightModeName;
	data.combined=combined;
	data.lateral=lateral;
	data.longitudinal=longitudinal;
	data.airframe=airframe;
	data.actuator=actuator;
	data.complete=complete;
	return data
endfunction
