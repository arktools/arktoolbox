function plotCov2D(P,xc,yc,varargin)

	[lhs,rhs] = argn();

	if (rhs > 3)
		plotSpecs = varargin(1);
	else
		plotSpecs = 'k-';	
	end

	if (rhs == 0)
		scf(1); clf(1);
        rand('gaussian')
		disp('rand(''gaussian'')')
        plotCov2D(rand(2,2),rand(1),rand(1))
        plotCov2D(rand(2,2),rand(1),rand(1))
        plotCov2D(rand(2,2),rand(1),rand(1))
        plotCov2D(rand(2,2),rand(1),rand(1))
        disp('plotCov2D(rand(2,2),rand(1),rand(1))')
		return;
	end

    t=linspace(0,2*%pi,100);
    [U,eVal,eVec] = svd(P);
    a = sqrt(eVal(1,1));
    b = sqrt(eVal(2,2));
    psi = atan(eVec(2,1),eVec(1,1));
    x = xc + a*cos(t)*cos(psi) - b*sin(t)*sin(psi);
    y = yc + a*cos(t)*sin(psi) + b*sin(t)*cos(psi);
    plot(xc+[0,a*eVec(1,1)],yc+[0,a*eVec(2,1)],'r-');
    plot(xc+[0,b*eVec(1,2)],yc+[0,b*eVec(2,2)],'g-');
    plot(x,y,plotSpecs)

endfunction
