
% Annika Rings, June 2017
%Script for reading Excel files with touchtimes of individual experiment
%and finding the corresponding results of deltaF/F of the experiment
%plots the experimental data with shaded areas for the touchtimes

clear all; 

%% 1. Set constants, variables and local functions

framerate = 5.92; % frame rate in Hz

numberframes=500;% number of frames
duration_acquisition = numberframes/framerate; 

startdir=pwd;
pathname='/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/P1_female_touch/touchtimes_active';

touchdir = ('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/P1_female_touch/touchtimes_active');
% The folder where the touchtimes files are located
resultsdir = ('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/P1_female_touch/Results_P1');
% The folder where the results of single experiments are located
outputdirmean=('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/P1_female_touch/Results_plot');
%The folder where the mean data should be written to
x = (1:numberframes)';% this is a column vector of the frame numbers
x= (x-1)/framerate;%calculate the timepoints of the frames from the frame number



ee = 1;
ii = 1;





 
%These are the strings that must appear in the names and specify which type
%of experiment it is. For example: 1p05s stands for 1 pulse of 5s
%namestrings=['1p05s.xlsx';'2p05s.xlsx';'4p05s.xlsx';'1p20s.xlsx';'2p20s.xlsx';'4p01s.xlsx';'1p01s.xlsx'];
%for nn = 1:size(namestrings,1)%loop through all namestrings
    %identify the correct pulsetimes from the name of the file
 %   pulsetimes=eval(strcat('pulsetimes',strrep(namestrings(nn,:),'.xlsx','')));
    %identify the pulseduration from the name of the file
  %  pulsedurstring=strrep(strcat('pulsedur',regexprep(namestrings(nn,:),'(\w)p','')),'.xlsx','');
   % pulsedur=eval(pulsedurstring);
 
cd(touchdir)
%find files with the namestring in it
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
                    
                        
                        outputfig=strcat(speciestype,'_',resultfilestring,numberstring,'.eps');%make the figure name
                        fignew=figure('Name',outputfig);
                        %plot the mean with a shaded area showing the SEM
                        h=plot(x,expresult,'r');
                        for numpatch = 1:size(touchtimes)%loop through the number of touches
                            %for each touch, generate a shaded area in the plot
                            
                            hpatch(numpatch)=patch([touchtimes(numpatch) touchtimes(numpatch)+0.2 touchtimes(numpatch)+0.2 touchtimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
                            %send the shaded area to the back of the graph
                            uistack(hpatch(numpatch), 'bottom');
                        end
                        cd(outputdirmean);
                        saveas(fignew,outputfig,'epsc');
                    end
                end
                clear expresults;
                clear expresult;
          
 
                
           

end
        
        
        %go back to directory of matlab scripts
        cd(startdir);



