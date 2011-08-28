function [f,fIndex] = zohAnalysisPlot(name,fIndex,sOpen,rates)
	sClosed = sOpen/(1+sOpen);
	f=scf(fIndex); clf(fIndex);
	f.figure_name=name + ' zero order hold effect, open/ closed loop';
	f.figure_size = [1200,600];
	set_posfig_dim(f.figure_size(1),f.figure_size(2));
	ratesLegend = [];
	if (size(rates,2) < 8)
		for j=1:size(rates,2)
			ratesLegend(j,1) = [string(rates(1,j)) + ' Hz'];
		end
	else
		ratesLegend = '';
	end

	// plots
	subplot(1,2,1);
	bode(zohPade(rates)*sOpen,0.01,99,.01,ratesLegend)
	subplot(1,2,2);
	bode(zohPade(rates)*sClosed,0.01,99,.01)
	xs2eps(fIndex,name+'_zoh_analysis');
	fIndex = fIndex +1;
endfunction

