function tests = aligntouchesTest
tests = functiontests(localfunctions);
end



function test_align_touches(testCase)
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