function [sysOut,uOut] = closeLoop(yi,ui,sys,y,u,H,loopType)
// close a loop
// loopType : ff -> feed forward loop controller, fb -> feed back loop controller
	printf('\tclosing loop: %s\n',y.str(yi)+'->'+u.str(ui));
	openLoopAnalysis(H*sys(yi,ui));
	if (loopType=='ff')
		sysOut = unityFeedback(yi,ui,sys,H);
	elseif (loopType=='fb')
		sysOut = structuredFeedback(yi,ui,sys,H);
	else
		error('unknown type for closeLoop');
	end
		
	uOut = createIndex(y.str(yi),u);
	[eVect,eVal] = spec(abcd(sysOut));
	eVal = diag(eVal);
	unstablePoles=find(real(eVal)>0);
	printf('\t\tunstable modes:\n');
	for i=1:size(unstablePoles,2)
		[junk,k]=sort(eVect(:,unstablePoles(i)));
		j=0; // number of valid states found
		m=1; // index 
		printf('\t\t\t');
		while 1
			if (k(m)<=size(y.str,1))		
				j = j +1;
				printf('%9s\t',y.str(k(m)));
			end
			if (j>2)
				printf('\t%8.3f + %8.3f j\n',..
					real(eVal(unstablePoles(i))),..
					imag(eVal(unstablePoles(i))));
				break;
			else
				m = m +1;
			end;
		end
	end
	poles=size(abcd(sys),1);
	printf('\t\tunstable poles=%d/%d\n',size(unstablePoles,2),size(abcd(sysOut),1));
endfunction

