
% Annika Rings, Oct 2019
%PLOT_WITH_TOUCHES is a function that plots the fluorescence with
%shaded areas for touchtimes
%no required arguments
%if no arguments are specified, defaults are used
%optional key-value pair arguments are:
%framerate: calcium imaging framerate (in Hz), default 5.92
%touchdir: directory with touchtimes files
%resultsdir: directory with imaging results files
%outputdirmean: directory that results should be written to
%reduced: whether or not reduced touchtimes format is used; default:
%determine this from the name of the touchdir (based on whether this name contains
%the string 'reduced')
%dependencies: options_resolver.m


function plot_with_touches(varargin)
arguments=varargin;
 options = struct('framerate',5.92,'numberframes',600,'touchdir','/Volumes/LaCie/Projects/Matthew/touchtimes','resultsdir','/Volumes/LaCie/Projects/Matthew/Results','outputdirmean','/Volumes/LaCie/Projects/Matthew/Results','reduced',false);
%call the options_resolver function to check optional key-value pair
%arguments
[options,override_reduced]=options_resolver(options,arguments,'plot_with_touches');
%setting the values for optional arguments
framerate = options.framerate;
numberframes = options.numberframes;
touchdir = options.touchdir;
resultsdir = options.resultsdir;
outputdirmean=options.outputdirmean;
reduced = options.reduced;

startdir=pwd;
x = (1:numberframes)';% this is a column vector of the frame numbers
x= (x-1)/framerate;%calculate the timepoints of the frames from the frame number
duration_acquisition = numberframes/framerate;

ee = 1;
ii = 1;
%determine whether reduced touchtimes format was used
if ~override_reduced
    if contains (touchdir, 'reduced')
        reduced =1;
    else
        reduced =0;
    end
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
            
           
            
                touchtimes_l = table2array(readtable(filename,'Range','E:E','ReadVariableNames',1));
                touchtimes_r = table2array(readtable(filename,'Range','I:I','ReadVariableNames',1));
                touchtimes = [touchtimes_l;touchtimes_r];
                
               
               
               resultfilestring=strrep((regexprep(filename,'_(\d+).xlsx','_')),'touchtimes_','');
               numberstring=strrep((regexprep(filename,'touchtimes_(\d+)_(\d+)_(\d+)_','')),'.xlsx','');
               
               
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



