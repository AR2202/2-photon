function tests = aligntouchesTest
tests = functiontests(localfunctions);
end


%this is the general test for the function
function test_align_touches(testCase)
load(fullfile('testdata/mean_male_touch.mat'), 'male_mean_event_m', 'male_SEM_event_m');
expSolution_mean = male_mean_event_m;
expSolution_SEM = male_SEM_event_m;


align_touches('touchdir', 'touchtimes_reduced', 'resultsdir', 'Results_test', 'outputdirmean', 'Results_test');
load(fullfile('Results_test/mean_male_touch.mat'), 'male_mean_event_m', 'male_SEM_event_m');
actSolution_mean = male_mean_event_m;
actSolution_SEM = male_SEM_event_m;
verifyEqual(testCase, actSolution_mean, expSolution_mean);
verifyEqual(testCase, actSolution_SEM, expSolution_SEM);

end

%this test verifies that data from different days with same fly number do
%not get treated as data from the same fly
function test_align_touches_different_files_same_flynumb(testCase)
load(fullfile('testdata/mean_male_touch.mat'), 'male_mean_event_m', 'male_SEM_event_m');
expSolution_mean = male_mean_event_m;
expSolution_SEM = male_SEM_event_m;


align_touches('touchdir', 'touchtimes_mock_reduced', 'resultsdir', 'Results_test', 'outputdirmean', 'Results_test');
load(fullfile('Results_test/mean_male_touch.mat'), 'male_mean_event_m', 'male_SEM_event_m');
actSolution_mean = male_mean_event_m;
actSolution_SEM = male_SEM_event_m;
verifyNotEqual(testCase, actSolution_mean, expSolution_mean);
verifyNotEqual(testCase, actSolution_SEM, expSolution_SEM);

end


function test_align_touches_female(testCase)
load(fullfile('testdata/mean_female_touch.mat'), 'male_mean_event_f', 'male_SEM_event_f');
expSolution_mean = male_mean_event_f;
expSolution_SEM = male_SEM_event_f;


align_touches('touchdir', 'touchtimes_mock_reduced', 'resultsdir', 'Results_test', 'outputdirmean', 'Results_test');
load(fullfile('Results_test/mean_female_touch.mat'), 'male_mean_event_m', 'male_SEM_event_m');
actSolution_mean = male_mean_event_m;
actSolution_SEM = male_SEM_event_m;
verifyEqual(testCase, actSolution_mean, expSolution_mean);
verifyEqual(testCase, actSolution_SEM, expSolution_SEM);

end
%this test currently fails - function align_touches can't handle missing data
%needs to be updated

function test_align_touches_missing_data(testCase)
load(fullfile('testdata/mean_male_touch.mat'), 'male_mean_event_m', 'male_SEM_event_m');
expSolution_mean = male_mean_event_m;
expSolution_SEM = male_SEM_event_m;


align_touches('touchdir', 'touchtimes_missing_data', 'resultsdir', 'Results_test', 'outputdirmean', 'Results_test', 'reduced', true);
load(fullfile('Results_test/mean_male_touch.mat'), 'male_mean_event_m', 'male_SEM_event_m');
actSolution_mean = male_mean_event_m;
actSolution_SEM = male_SEM_event_m;
verifyEqual(testCase, actSolution_mean, expSolution_mean);
verifyEqual(testCase, actSolution_SEM, expSolution_SEM);

end