function info=defineIndex(names)
// Used to define string/ indices for system
	len=size(names,1)
	for i=1:len
		execstr('info.'+names(i)+'=i')
		execstr('info.str(i)=names(i)')
	end
endfunction

