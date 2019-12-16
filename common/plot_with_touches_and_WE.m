
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


function plot_with_touches_and_WE(varargin)
arguments=varargin;
 options = struct('framerate',5.92,'numberframes',600,'touchdir','touchtimes','resultsdir','Results','outputdirmean','Results_WE_and_touch','reduced',false,'multiroi',false,'pulsetimes',[20,40,60,80]);
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
multiroi=options.multiroi;
pulsetimes = options.pulsetimes;

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
            
           
            filename = files{ii}{ee}{gg};
            
           
            
                touchtimes = table2array(readtable(filename,'Range','E:E','ReadVariableNames',1));
                wingtimes = table2array(readtable(filename,'Range','G:G','ReadVariableNames',1));
                
                
               
               
               resultfilestring=strrep((regexprep(filename,'_(\d+).xlsx','_')),'touchtimes_','');
               numberstring=strrep((regexprep(filename,'touchtimes_(\d+)_(\d+)_(\d+)_','')),'.xlsx','');
               
               cd(startdir);
                cd(resultsdir);
                resultfiles = dir(strcat(resultfilestring,'*.xlsx'));
                resultfiles = {resultfiles.name};
                for ff = 1:length(resultfiles)
                   
                    resultfilename=resultfiles{ff};
                    speciestype=strrep((strrep(resultfilename,resultfilestring,'')),'.xlsx','');
                    
                    expnames =table2array(readtable(resultfilename,'Sheet','Sheet2','ReadVariableNames',0));
                    findnumberstring=strfind(expnames,numberstring);
                    foundfile=find(~cellfun(@isempty,findnumberstring));
                    
                   
                    if ~isempty(foundfile)
                        for n = 1:numel(foundfile)
                        expnumb=foundfile(1,n);
                        expresults =table2array(readtable(resultfilename,'Sheet','Sheet1','ReadVariableNames',0));
                        expresult=expresults(:,expnumb);
                        expbase = mean(expresult(6:60));
                        dff=(expresult-expbase)/expbase;
                        expname =expnames(:,expnumb);
                        pulsedurstring=regexp(expname,'((\d)s|(\d\d\d)ms)','match');
                        pulsedurstring=pulsedurstring{1};
                        %disp(pulsedurstring{1});
                        if contains(pulsedurstring,'ms')
                            pulsedur = str2double(strrep(pulsedurstring,'ms',''))/1000;
                        else
                            pulsedur = str2double(strrep(pulsedurstring,'s',''));
                    
                        end
                        outputfig=strcat(speciestype,'_',resultfilestring,numberstring,'.eps');%make the figure name
                        fignew=figure('Name',outputfig,'Units','centimeters','Position',[10 10 15 5]);
                        %plot the mean with a shaded area showing the SEM

                        h=plot(x,dff,'k');
                                                xlim([0,100]);
                        ylim([-1,1]);
                        %title('Frequency');
                        xlabel('s');
                        ylabel ('\DeltaF/F');
                        ax = gca;
                        ax.FontSize = 13;
                        ax.LineWidth=2;
                        if reduced
                            disp('Reduced touchtimes format was used.');
                            for numpatch = 1:numel(pulsetimes)
                                %for each optogenetic pulse, generate a shaded area in the plot
                                
                                hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'r','EdgeColor','none');
                                %send the shaded area to the back of the graph
                                uistack(hpatch(numpatch), 'bottom');
                                
                                
                            end
                            for numpatch = 1:(floor(size(touchtimes)/2))%loop through the number of touches
                                %for each touch, generate a shaded area in the plot
                                index=2*numpatch-1;
                                hpatch(index)=patch([touchtimes(index) touchtimes(index+1) touchtimes(index+1) touchtimes(index)] , [min(ylim)*[1 1] max(ylim)*[1 1]],[(166/255) (172/255) (175/255)],'EdgeColor','none');
                                %send the shaded area to the back of the graph
                                uistack(hpatch(index), 'bottom');
                                
                            end
                            for numpatch = 1:(floor(size(wingtimes)/2))%loop through the number of touches
                                %for each touch, generate a shaded area in the plot
                                index=2*numpatch-1;
                                hpatch(index)=patch([wingtimes(index) wingtimes(index+1) wingtimes(index+1) wingtimes(index)] , [min(ylim)*[1 1] max(ylim)*[1 1]],[(230/255) (176/255) (170/255)],'EdgeColor','none');
                                %send the shaded area to the back of the
                                %graph/255)
                                uistack(hpatch(index), 'bottom');
                                
                            end
                            

                        else
                            for numpatch = 1:numel(pulsetimes)
                                %for each optogenetic pulse, generate a shaded area in the plot
                                
                                hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'r','EdgeColor','none');
                                %send the shaded area to the back of the graph
                                uistack(hpatch(numpatch), 'bottom');
                                
                                
                            end
                            for numpatch = 1:size(touchtimes)%loop through the number of touches
                                %for each touch, generate a shaded area in the plot
                                
                                hpatch(numpatch)=patch([touchtimes(numpatch) touchtimes(numpatch)+0.2 touchtimes(numpatch)+0.2 touchtimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],[(166/255) (172/255) (175/255)],'EdgeColor','none');
                                %send the shaded area to the back of the graph
                                uistack(hpatch(numpatch), 'bottom');
                            end
                            for numpatch = 1:size(wingtimes)%loop through the number of touches
                                %for each touch, generate a shaded area in the plot
                                
                                hpatch(numpatch)=patch([wingtimes(numpatch) wingtimes(numpatch)+0.2 touchtimes(numpatch)+0.2 touchtimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],[(230/255) (176/255) (170/255)],'EdgeColor','none');
                                %send the shaded area to the back of the graph
                                uistack(hpatch(numpatch), 'bottom');
                            end
                            
                        end
                        cd(startdir);
                        cd(outputdirmean);
                        saveas(fignew,outputfig,'epsc');
                        cd(startdir);
                        cd(resultsdir);
                        end
                    end
                end
                clear expresults;
                clear expresult;
                cd(startdir);
          cd(touchdir);
 
                
           

end
        
        
        %go back to directory of matlab scripts
        cd(startdir);



