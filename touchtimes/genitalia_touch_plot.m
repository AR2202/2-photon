
% Annika Rings, June 2017
%Script for reading Excel files with touchtimes of individual experiment
%and finding the corresponding results of deltaF/F of the experiment
%plots the experimental data with shaded areas for the touchtimes
%modified version for Matthew's data

clear all; 

%% 1. Set constants, variables and local functions

framerate = 5.92; % frame rate in Hz

numberframes=600;% number of frames
duration_acquisition = numberframes/framerate; 

startdir=pwd;
pathname='/Volumes/LaCie/Projects/Matthew/touchtimes';

touchdir = ('/Volumes/LaCie/Projects/Matthew/touchtimes');
% The folder where the touchtimes files are located
resultsdir = ('/Volumes/LaCie/Projects/Matthew/Results');
% The folder where the results of single experiments are located
outputdirmean=('/Volumes/LaCie/Projects/Matthew/Results');
%The folder where the mean data should be written to

function plot_with_touches(varargin)
options = struct('scaling',1,'wingdur',13,'wingextonly',true,'minwingangle',30,'fromscores',false,'windowsize',13,'cutofffrac',0.5,'score','WingGesture','specificframes',false,'filterby',0,'cutoffval',2,'above',true);
%# read the acceptable names
optionNames = fieldnames(options);

%# count arguments - throw exception if the number is not divisible by 2
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
    error('pdfplot_any called with wrong number of arguments: expected Name/Value pair arguments')
end

for pair = reshape(varargin,2,[]) %# pair is {propName;propValue}
    inpName = lower(pair{1}); %# make case insensitive
    %check if the entered key is a valid key. If yes, replace the default by
    %the caller specified value. Otherwise, throw and exception
    if any(strcmp(inpName,optionNames))
        
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end
x = (1:numberframes)';% this is a column vector of the frame numbers
x= (x-1)/framerate;%calculate the timepoints of the frames from the frame number



ee = 1;
ii = 1;
if contains (touchdir, 'reduced')
    reduced =1;
else
reduced =0;
end



 

 
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
                    if ~isempty(foundfile)
                        expnumb=foundfile(1,1);
                        expresults =table2array(readtable(resultfilename,'Sheet','Sheet1','ReadVariableNames',0));
                        expresult=expresults(:,expnumb);
                    
                        
                        outputfig=strcat(speciestype,'_',resultfilestring,numberstring,'.eps');%make the figure name
                        fignew=figure('Name',outputfig);
                        %plot the mean with a shaded area showing the SEM
                        h=plot(x,expresult,'r');
                        if reduced
                            disp('Reduced touchtimes format was used.');
                            for numpatch = 1:(size(touchtimes)/2)%loop through the number of touches
                                %for each touch, generate a shaded area in the plot
                                index=2*numpatch-1;
                                hpatch(index)=patch([touchtimes(index) touchtimes(index+1) touchtimes(index+1) touchtimes(index)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
                                %send the shaded area to the back of the graph
                                uistack(hpatch(index), 'bottom');
                                
                            end
                        else
                            for numpatch = 1:size(touchtimes)%loop through the number of touches
                                %for each touch, generate a shaded area in the plot
                                
                                hpatch(numpatch)=patch([touchtimes(numpatch) touchtimes(numpatch)+0.2 touchtimes(numpatch)+0.2 touchtimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
                                %send the shaded area to the back of the graph
                                uistack(hpatch(numpatch), 'bottom');
                            end
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



