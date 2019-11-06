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


function test_genitalia_touch(testCase)
load(fullfile('testdata/testdat_genitalia_touch.mat'),'dff','virgindff','virginf','filenames');
expSolution_dff=dff;
expSolution_virgindff=virgindff;
expSolution_virginf=virginf;
expSolution_filenames=filenames;

[actSolution_dff, actSolution_virgindff,actSolution_virginf,actSolution_filenames] = genitalia_touch('testdata','outputdir','Results_test');

verifyEqual(testCase,actSolution_dff,expSolution_dff);
verifyEqual(testCase,actSolution_virgindff,expSolution_virgindff);
verifyEqual(testCase,actSolution_virginf,expSolution_virginf);
verifyEqual(testCase,actSolution_filenames,expSolution_filenames);
end