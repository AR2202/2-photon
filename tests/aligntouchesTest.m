function tests = aligntouchesTest
tests = functiontests(localfunctions);
end




function test_align_touches(testCase)
load(fullfile('testdata/mean_male_touch.mat'),'male_mean_event_m','male_SEM_event_m');
expSolution_mean=male_mean_event_m;
expSolution_SEM=male_SEM_event_m;


align_touches('touchdir','touchtimes_reduced','resultsdir','Results_test','outputdirmean','Results_test');
load(fullfile('Results_test/mean_male_touch.mat'),'male_mean_event_m','male_SEM_event_m');
actSolution_mean=male_mean_event_m;
actSolution_SEM=male_SEM_event_m;
verifyEqual(testCase,actSolution_mean,expSolution_mean);
verifyEqual(testCase,actSolution_SEM,expSolution_SEM);

end