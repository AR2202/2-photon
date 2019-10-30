%Annika Rings, Oct 2019
%OPTIONS_RESOLVER is a function which checks optional key-value-pair
%arguments
%to be called from within a function that takes optional key-value-pair
%arguments
%the arguments are: 
%options: a structure of acceptable key-value pairs
%args: a cell array of the arguments passed in by the caller to the top
%level function
%funcname: the name of the top-level function (as a string)

function [options, override_reduced]=options_resolver(options,args,funcname)
%# read the acceptable names
optionNames = fieldnames(options);

%# count arguments - throw exception if the number is not divisible by 2
nArgs = length(args);
if round(nArgs/2)~=nArgs/2
    error(strcat(funcname, ' called with wrong number of arguments: expected Name/Value pair arguments'))
end
override_reduced=0;
for pair = reshape(args,2,[]) %# pair is {propName;propValue}
    inpName = lower(pair{1}); %# make case insensitive
    %check if reduced was specified by caller, if so override the default setting for
    %how reduced is determined
    if strcmp(inpName, 'reduced')
        disp('manually overriding reduced touchtimes identifier')
        override_reduced=1;
    end
    %check if the entered key is a valid key. If yes, replace the default by
    %the caller specified value. Otherwise, throw and exception
    if any(strcmp(inpName,optionNames))
        
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end
