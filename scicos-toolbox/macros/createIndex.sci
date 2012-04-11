function  infoNew = createIndex(names,info)
// Used to define string/ indices for system
// example:
// 	data = createIndex(["V","h","theta"]);
// 	data.str(1) -> "V"
// 	data.V -> 1 

    // check if we are appending
    if (argn(2) == 2)
        iStart = max(size(info.str));
    else
        iStart = 0;
    end

    // add strings
     for i=1:max(size(names))
        execstr('info.str(i+iStart)=names(i)')
    end

    // add new indices
    for i=1:max(size(names))
        execstr('info.'+names(i)+'=i+iStart')
    end
    
    // output modified info
    infoNew = info;
endfunction
// vim:ts=4:sw=4:expandtab
