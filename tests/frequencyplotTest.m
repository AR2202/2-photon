function tests = frequencyplotTest
tests = functiontests(localfunctions);
end


%this is the general test for the function
function test_frequencyplot(testCase)

load(fullfile('../Results_test/testdata10ms_10Hz_male_AOTu_5s.mat'),'dff','SEM_dff','mean_dff','mean_first_dff','mean_pulseav_dff','pulsedff');
expSolution_mean=mean_dff;
expSolution_SEM=SEM_dff;
expSolution_dff=dff;
expSolution_mean_first=mean_first_dff;
expSolution_mean_pulseav_dff=mean_pulseav_dff;
expSolution_pulsedff=pulsedff;


frequencyplot('imaging_preprocessed','resultsdir','../Results_test','frequencies',[10,20,40,80],'pulselengths',[10],'neuronparts',{'AOTu'})

load(fullfile('../Results_test/10ms_10Hz_male_AOTu_5s.mat'),'dff','SEM_dff','mean_dff','mean_first_dff','mean_pulseav_dff','pulsedff');
actSolution_mean=mean_dff;
actSolution_SEM=SEM_dff;
actSolution_dff=dff;
actSolution_mean_first=mean_first_dff;
actSolution_mean_pulseav_dff=mean_pulseav_dff;
actSolution_pulsedff=pulsedff;
verifyEqual(testCase,actSolution_mean,expSolution_mean);
verifyEqual(testCase,actSolution_SEM,expSolution_SEM);
verifyEqual(testCase,actSolution_dff,expSolution_dff);
verifyEqual(testCase,actSolution_mean_first,expSolution_mean_first);
verifyEqual(testCase,actSolution_mean_pulseav_dff,expSolution_mean_pulseav_dff);
verifyEqual(testCase,actSolution_pulsedff,expSolution_pulsedff);
close all;
clearvars;

end
%this is a test with different pulselengths but only one gender

function test_frequencyplot_different_pulselength(testCase)

load(fullfile('../Results_test/testdata20ms_40Hz_male_AOTu_5s.mat'),'dff','SEM_dff','mean_dff','mean_first_dff','mean_pulseav_dff','pulsedff');
expSolution_mean=mean_dff;
expSolution_SEM=SEM_dff;
expSolution_dff=dff;
expSolution_mean_first=mean_first_dff;
expSolution_mean_pulseav_dff=mean_pulseav_dff;
expSolution_pulsedff=pulsedff;


frequencyplot('imaging_preprocessed','resultsdir','../Results_test','frequencies',[40],'pulselengths',[10,20],'neuronparts',{'AOTu'},'genders',{'_male'})

load(fullfile('../Results_test/20ms_40Hz_male_AOTu_5s.mat'),'dff','SEM_dff','mean_dff','mean_first_dff','mean_pulseav_dff','pulsedff');
actSolution_mean=mean_dff;
actSolution_SEM=SEM_dff;
actSolution_dff=dff;
actSolution_mean_first=mean_first_dff;
actSolution_mean_pulseav_dff=mean_pulseav_dff;
actSolution_pulsedff=pulsedff;
verifyEqual(testCase,actSolution_mean,expSolution_mean);
verifyEqual(testCase,actSolution_SEM,expSolution_SEM);
verifyEqual(testCase,actSolution_dff,expSolution_dff);
verifyEqual(testCase,actSolution_mean_first,expSolution_mean_first);
verifyEqual(testCase,actSolution_mean_pulseav_dff,expSolution_mean_pulseav_dff);
verifyEqual(testCase,actSolution_pulsedff,expSolution_pulsedff);
close all;
clearvars;

end
%tests whether the function works on a subdirectory of
%'imaging_preprocessed';
function test_frequencyplot_onedir(testCase)

load(fullfile('../Results_test/testdata10ms_40Hz_male_AOTu_5s.mat'),'dff','SEM_dff','mean_dff','mean_first_dff','mean_pulseav_dff','pulsedff');
expSolution_mean=mean_dff;
expSolution_SEM=SEM_dff;
expSolution_dff=dff;
expSolution_mean_first=mean_first_dff;
expSolution_mean_pulseav_dff=mean_pulseav_dff;
expSolution_pulsedff=pulsedff;
currentdir =pwd;
cd('imaging_preprocessed');
frequencyplot('2020_01_16','resultsdir','../Results_test','frequencies',[40],'pulselengths',[10],'neuronparts',{'AOTu'},'genders',{'_male'})
cd (currentdir);
load(fullfile('../Results_test/10ms_40Hz_male_AOTu_5s.mat'),'dff','SEM_dff','mean_dff','mean_first_dff','mean_pulseav_dff','pulsedff');
actSolution_mean=mean_dff;
actSolution_SEM=SEM_dff;
actSolution_dff=dff;
actSolution_mean_first=mean_first_dff;
actSolution_mean_pulseav_dff=mean_pulseav_dff;
actSolution_pulsedff=pulsedff;
verifyEqual(testCase,actSolution_mean,expSolution_mean);
verifyEqual(testCase,actSolution_SEM,expSolution_SEM);
verifyEqual(testCase,actSolution_dff,expSolution_dff);
verifyEqual(testCase,actSolution_mean_first,expSolution_mean_first);
verifyEqual(testCase,actSolution_mean_pulseav_dff,expSolution_mean_pulseav_dff);
verifyEqual(testCase,actSolution_pulsedff,expSolution_pulsedff);

close all;
clearvars;

end

%test loading stimtimes from a file
function test_frequencyplot_stimtimes(testCase)

load(fullfile('../Results_test/testdata_stimtimes_10ms_40Hz_male_AOTu_5s.mat'),'dff','SEM_dff','mean_dff','mean_first_dff','mean_pulseav_dff','pulsedff');
expSolution_mean=mean_dff;
expSolution_SEM=SEM_dff;
expSolution_dff=dff;
expSolution_mean_first=mean_first_dff;
expSolution_mean_pulseav_dff=mean_pulseav_dff;
expSolution_pulsedff=pulsedff;

frequencyplot('imaging_preprocessed','resultsdir','../Results_test','frequencies',[40],'pulselengths',[10],'neuronparts',{'AOTu'},'genders',{'_male'},'pulsetimesfromfile', true)

load(fullfile('../Results_test/10ms_40Hz_male_AOTu_5s.mat'),'dff','SEM_dff','mean_dff','mean_first_dff','mean_pulseav_dff','pulsedff');
actSolution_mean=mean_dff;
actSolution_SEM=SEM_dff;
actSolution_dff=dff;
actSolution_mean_first=mean_first_dff;
actSolution_mean_pulseav_dff=mean_pulseav_dff;
actSolution_pulsedff=pulsedff;
verifyEqual(testCase,actSolution_mean,expSolution_mean);
verifyEqual(testCase,actSolution_SEM,expSolution_SEM);
verifyEqual(testCase,actSolution_dff,expSolution_dff);
verifyEqual(testCase,actSolution_mean_first,expSolution_mean_first);
verifyEqual(testCase,actSolution_mean_pulseav_dff,expSolution_mean_pulseav_dff);
verifyEqual(testCase,actSolution_pulsedff,expSolution_pulsedff);

close all;
clearvars;

end