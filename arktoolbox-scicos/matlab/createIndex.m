function  dataNew = createIndex(names,data)
% createIndex.m
%
% Used to define string/ indices for system
%
% example:
%
% define indices for x
%   x = createIndex({'V','h','theta'});
%
% append some more states to x
%   x = createIndex({'a','bc','def'},x);
%
% access the index for V
%   x.V -> 1
%
% access the string for index 1
%   x.str(1) -> 'V' 
%
% to run a demo call createIndex()   (with no arguments)
%
% Copyright 2011 James Goppert
% Released under GPL v3 License
%

    % check if we are appending
    if (nargin == 0)
        % demonstates the createIndex function
        fprintf('you failed to provide any arguments, i will show a demo of the usage\n');
        fprintf('create index is used to keep component names and numbers tied together\n');
        fprintf('assume our state vector was  x = {''V'',''h'',''theta''}\n');
        fprintf('just call x = createIndex({''V'',''h'',''theta''})\n');
        index = createIndex({'V','h','theta'})
        fprintf('\naccess the name off the first variable:\n');
        fprintf('index.str(1) : %s\n',char(index.str(1)));
        fprintf('\naccess the index of the ''V'' variable:\n');
        fprintf('index.V : %d\n', index.V)
        fprintf('\nappend more varibles to a current index\n');
        fprintf('index = createIndex({''a'',''bc'',''def''},index);\n');
        index = createIndex({'a','bc','def'},index)
        return;
    elseif (nargin == 2)
        iStart = max(size(data.str));
    elseif (nargin == 1)
        iStart = 0;
    else
        disp('incorrect number of arguments, 0 for demo, else (names,info), or (names)');
    end

    % add strings
     for i=1:max(size(names))
        eval('data.str(i+iStart)=cellstr(char(names(i)));');
     end

    % add new indices
    for i=1:max(size(names))
        eval(strcat('data.',char(names(i)),'=i+iStart;'));
    end
    
    % output modified info
    dataNew = data;
end
% vim:ts=4:sw=4:expandtab