
% Annika Rings, June 2017
%Script for reading Excel files with touchtimes of individual experiment
%and finding the corresponding results of deltaF/F of the experiment
%finds peaks of deltaF/F during touch events
%any touches occuring within 5s of a previous touch are treated as a single
%touch event
%peaks are calculated as deltaF/F0, where F0 is the baseline calculated as
%the average of 10 frames 1s before the start of the touch event

%averages all peaks of a single experiment
%reports the experiment means and the overall mean per species type

%saves results in a seperate excel file for each species type

clear all; 

%% 1. Set constants, variables and local functions

framerate = 5.92; % frame rate in Hz

numberframes=500;% number of frames
duration_acquisition = numberframes/framerate; 

startdir=pwd;
pathname='/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/dsx-GABA-female_male_touch/touchtimes_files';
%pathname has to be the path to the folder were files to be processed are
%located

touchdir = ('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/dsx-GABA-female_male_touch/touchtimes_files');
% The folder where the touchtimes files are located
resultsdir = ('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/dsx-GABA-female_male_touch/Results_dsx-GABA');
% The folder where the results of single experiments are located
outputdirmean=('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/dsx-GABA-female_male_touch/Results_mean');
%The folder where the mean data should be written to
x = (1:numberframes)';% this is a column vector of the frame numbers
x= (x-1)/framerate;%calculate the timepoints of the frames from the frame number



ee = 1;
ii = 1;




species = {'virgin' 'male' 'yakuba' 'simulans'};
for ind = 1:length(species)
  s.(species{ind}) = [];
end
for ind = 1:length(species)
  n_singles.(species{ind}) = [];
end
for ind = 1:length(species)
  expfiles.(species{ind}) = {};
end
 

 
cd(touchdir)

files{ii}{ee} = dir('*.xlsx');
files{ii}{ee} = {files{ii}{ee}.name};
 
filenames = cell((length(files{ii}{ee})),1);
filenames(:) = {''};

        % loop through excel files with that namestring
        for gg = 1:length(files{ii}{ee})
            
            % go back into the stack directory
            cd(touchdir);
            filename = files{ii}{ee}{gg};
            %[~, sheets] = xlsfinfo(filename);
           
            
                touchtimes = table2array(readtable(filename,'Range','E:E','ReadVariableNames',1));
                touchframes = table2array(readtable(filename,'Range','D:D','ReadVariableNames',1));
                startframe =  table2array(readtable(filename,'Range','A2:A2','ReadVariableNames',0));
               % disp(touchtimes); %for debugging
               %disp(touchframes);%for debugging
               %disp(startframe);
               resultfilestring=strrep((regexprep(filename,'_(\d+).xlsx','_')),'touchtimes_','');
               numberstring=strrep((regexprep(filename,'touchtimes_(\d+)_(\d+)_(\d+)_','')),'.xlsx','');
               
               %disp(resultfilestring);
                cd(resultsdir);
                resultfiles = dir(strcat(resultfilestring,'*.xlsx'));
                resultfiles = {resultfiles.name};
                for ff = 1:length(resultfiles)
                    cd(resultsdir);
                    resultfilename=resultfiles{ff};
                    speciestype=strrep((strrep(resultfilename,resultfilestring,'')),'.xlsx','');
                    expnames =table2array(readtable(resultfilename,'Sheet','Sheet2','ReadVariableNames',0));
                    findnumberstring=strfind(expnames,numberstring);
                    foundfile=find(~cellfun(@isempty,findnumberstring));
                   % disp(foundfile);
                    if isempty(foundfile)==0
                        expnumb=foundfile(1,1);
                        expresults =table2array(readtable(resultfilename,'Sheet','Sheet1','ReadVariableNames',0));
                        expresult=expresults(:,expnumb);
                    
                        
                        %outputfig=strcat(speciestype,'_',resultfilestring,numberstring,'.eps');%make the figure name
                        %fignew=figure('Name',outputfig);
                        %plot the mean 
                        %h=plot(x,expresult,'r');
                        touchstart=touchtimes(1);
                        for touches = 2:size(touchtimes)%loop through the number of touches
                                 touchstartframe=round(touchstart*framerate+1);
                                if (touchtimes(touches)-touchtimes(touches-1))>=5
                                    
                                   
                                    touchend=touchtimes(touches-1);
                                    touchendframe=round(touchend*framerate);
                                    if(touchstartframe-16)>=1
                                        before=mean(expresult((touchstartframe-16):(touchstartframe-6)));
                                    else    
                                        before=mean(expresult(1:10));
                                    end
                                    touchpeak=max(expresult(touchstartframe:touchendframe+12))-before;
                                    if exist('touchpeaks')==1
                                        touchpeaks=vertcat(touchpeaks,touchpeak);
                                    else
                                        touchpeaks=touchpeak;
                                    end
                                    touchstart=touchtimes(touches);
                                    
                                end
                        end
                        touchend=touchtimes(touches);%analyze the last touch
                        touchendframe=round(touchend*framerate);
                       
                                    before=mean(expresult((touchstartframe-16):(touchstartframe-6)));
                                    touchpeak=max(expresult(touchstartframe:touchendframe))-before;
                                    if exist('touchpeaks')==1
                                        touchpeaks=vertcat(touchpeaks,touchpeak);
                                    else
                                        touchpeaks=touchpeak;
                                    end
                        
                        %disp(touchpeaks); %debugging
                        mean_touchpeak=mean(touchpeaks);
                        n_touchpeak=size(touchpeaks,1);
                        s.(speciestype)=vertcat(s.(speciestype),mean_touchpeak);
                         n_singles.(speciestype)=vertcat(n_singles.(speciestype),n_touchpeak);
                         expfiles.(speciestype)=vertcat(expfiles.(speciestype),filename);
                        
                       
                        
                        
                        
                        
                       
                    end
                end
                clear expresults;
                clear expresult;
          
 
                
           

        end
        
cd(outputdirmean);
plotdata=[];
ploterror=[];
for ind = 1:length(species)
    means.(species{ind}) = mean([s.(species{ind})]);
    ns.(species{ind})=size(([s.(species{ind})]),1);
    SEMs.(species{ind})=std(([s.(species{ind})]),0,1)/sqrt([ns.(species{ind})]);
    outputfile=strcat(species{ind},'_touch_means.xlsx');
    outputfig=strcat(species{ind},'_touch_means.eps')
    %Tm=table([means.(species{ind})],[SEMs.(species{ind})],[ns.(species{ind})]);
    Tm=table([means.(species{ind})]);
    TSEM=table(SEMs.(species{ind}));
    Tn=table(ns.(species{ind}));
    Tsingle=table(s.(species{ind}));
    Tnames=table(expfiles.(species{ind}));
    
    writetable(Tm,outputfile,'Sheet','mean','Range','A1','WriteVariableNames',false);
    writetable(TSEM,outputfile,'Sheet','mean','Range','B1','WriteVariableNames',false);
    writetable(Tn,outputfile,'Sheet','mean','Range','C1','WriteVariableNames',false);
    writetable(Tsingle,outputfile,'Sheet','single','Range','D1','WriteVariableNames',false);
    writetable(Tnames,outputfile,'Sheet','single','Range','E1','WriteVariableNames',false);
    
    %the previous 2 lines give an error when one of the species types does not exist
    %ONLY use when all speciestypes specified in the species array are
    %present. otherwise, comment this out
    % needs to be fixed    
    %fignew=figure('Name',outputfig); 
    %for plotting single bars - otherwise comment out
                        
    %h=barwitherr((SEMs.(species{ind})),([means.(species{ind})]));
    plotdata=horzcat(plotdata,[means.(species{ind})]);
    ploterror=horzcat(ploterror,[SEMs.(species{ind})]);
  
end

%disp (s.simulans);
        fignew=figure('Name','all_species_means');
                        
    h=barwitherr(ploterror,plotdata);
    set(gca,'XTickLabel',species);
    saveas(fignew,'all_touch_means.eps','epsc');
  
        
        %go back to directory of matlab scripts
        cd(startdir);



