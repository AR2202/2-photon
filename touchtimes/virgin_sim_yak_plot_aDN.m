
% Annika Rings, June 2017
%Script for reading Excel files with touchtimes of individual experiment
%and finding the corresponding results of deltaF/F of the experiment
%plots the experimental data with shaded areas for the touchtimes

clear all; 

%% 1. Set constants, variables and local functions

framerate = 5.92; % frame rate in Hz

numberframes=600;% number of frames
duration_acquisition = numberframes/framerate; 

startdir=pwd;
pathname='/Volumes/LaCie/Projects/aDN/imaging/aDN_touch/touchtimes_GCaMP7_l_r_reduced';

touchdir = ('/Volumes/LaCie/Projects/aDN/imaging/aDN_touch/touchtimes_GCaMP7_l_r_reduced');
% The folder where the touchtimes files are located
resultsdir = ('/Volumes/LaCie/Projects/aDN/imaging/aDN_touch/Results');
% The folder where the results of single experiments are located
outputdirmean=('/Volumes/LaCie/Projects/aDN/imaging/aDN_touch/Results');
%The folder where the mean data should be written to
x = (1:numberframes)';% this is a column vector of the frame numbers
x= (x-1)/framerate;%calculate the timepoints of the frames from the frame number



ee = 1;
ii = 1;





 

 
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
           
            
                touchtimes_l = table2array(readtable(filename,'Range','E:E','ReadVariableNames',1));
                touchtimes_r = table2array(readtable(filename,'Range','I:I','ReadVariableNames',1));
                touchtimes = [touchtimes_l;touchtimes_r];
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
                        for numpatch = 1:(size(touchtimes)/2)%loop through the number of touches
                            %for each touch, generate a shaded area in the plot
                            index=2*numpatch-1;
                            hpatch(index)=patch([touchtimes(index) touchtimes(index+1) touchtimes(index+1) touchtimes(index)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
                            %send the shaded area to the back of the graph
                            uistack(hpatch(index), 'bottom');
                           
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



