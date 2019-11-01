function tests = genitaliatouchTest
tests = functiontests(localfunctions);
end

function testoptions_resolver_noargs(testCase)
options = struct('framerate',5.92,'numberframes',600,'touchdir','/Volumes/LaCie/Projects/Matthew/touchtimes','resultsdir','/Volumes/LaCie/Projects/Matthew/Results','outputdirmean','/Volumes/LaCie/Projects/Matthew/Results','reduced',false);
args={};
name='name';
[actSolution_options, actSolution_reduced] = options_resolver(options,args,name);
expSolution_options = options;
expSolution_reduced = 0;
verifyEqual(testCase,actSolution_options,expSolution_options);
verifyEqual(testCase,actSolution_reduced,expSolution_reduced);
end


function testoptions_resolver_withargs(testCase)
options = struct('framerate',5.92,'numberframes',600,'touchdir','/Volumes/LaCie/Projects/Matthew/touchtimes','resultsdir','/Volumes/LaCie/Projects/Matthew/Results','outputdirmean','/Volumes/LaCie/Projects/Matthew/Results','reduced',false);
args={'framerate', 7,'reduced',true};
name='name';
options_modified = struct('framerate',7,'numberframes',600,'touchdir','/Volumes/LaCie/Projects/Matthew/touchtimes','resultsdir','/Volumes/LaCie/Projects/Matthew/Results','outputdirmean','/Volumes/LaCie/Projects/Matthew/Results','reduced',true);

[actSolution_options, actSolution_reduced] = options_resolver(options,args,name);
expSolution_options = options_modified;
expSolution_reduced = 1;
verifyEqual(testCase,actSolution_options,expSolution_options);
verifyEqual(testCase,actSolution_reduced,expSolution_reduced);
end