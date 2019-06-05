
% Annika Rings, June 2017
%Script for reading Excel files with individual experiments/experimental
%days and calculating the mean of all the experiments in the folder
%writes the mean, SEM and number of experiments to Excel files
%plots mean and SEM and pulsetimes/durations and saves plots as .eps files
%Recognizes the type of experiment from the name of the file. The names
%must comply with the rules stated below

clear all; 

%% 1. Set constants, variables and local functions

framerate = 5.92; % frame rate in Hz

numberframes=600;% number of frames
duration_acquisition = numberframes/framerate; 

startdir=pwd;
pathname='/Volumes/LaCie/Projects/aDN/imaging/LC10-lexA_lexAop-CSChrimson_aDN_GCaMP6f/Results';
%pathname has to be the path to the folder were files to be processed are
%located

stackdir = ('/Volumes/LaCie/Projects/aDN/imaging/LC10-lexA_lexAop-CSChrimson_aDN_GCaMP6f/Results');
% The folder where the results of single experiments are located
outputdirmean=('/Volumes/LaCie/Projects/aDN/imaging/ppk23-lexA_aDN-GCaMP6f/Results');
%The folder where the mean data should be written to
x = (1:numberframes)';% this is a column vector of the frame numbers
x= (x-1)/framerate;%calculate the timepoints of the frames from the frame number



ee = 1;
ii = 1;

%specifies the time the led was switched for different experiment types
pulsetimes1p05s=[40];
pulsetimes1p20s=[40];
pulsetimes2p05s=[30,60];
pulsetimes4p05s=[20,40,60,80];
pulsetimes2p20s=[20,60];
pulsetimes4p01s=[20,40,60,80];
pulsetimes4p02s=[20,40,60,80];
%specifies the duration of the pulse
pulsedur05s=5;
pulsedur20s=20;
pulsedur01s=1;
pulsedur02s=2;



 
%These are the strings that must appear in the names and specify which type
%of experiment it is. For example: 1p05s stands for 1 pulse of 5s
namestrings=['4p05s.xlsx';'2p20s.xlsx';'4p01s.xlsx'];
for nn = 1:size(namestrings,1)%loop through all namestrings
    %identify the correct pulsetimes from the name of the file
    pulsetimes=eval(strcat('pulsetimes',strrep(namestrings(nn,:),'.xlsx','')));
    %identify the pulseduration from the name of the file
    pulsedurstring=strrep(strcat('pulsedur',regexprep(namestrings(nn,:),'(\w)p','')),'.xlsx','');
    pulsedur=eval(pulsedurstring);
 
cd(stackdir)
%find files with the namestring in it
%this is just for females
files{ii}{ee} = dir(strcat('*female_',namestrings(nn,:)));
files{ii}{ee} = {files{ii}{ee}.name};
 
filenames = cell((length(files{ii}{ee})),1);
filenames(:) = {''};

        % loop through excel files with that namestring
        for gg = 1:length(files{ii}{ee})
            
            % go back into the stack directory
            cd(stackdir);
            filename = files{ii}{ee}{gg};
            [~, sheets] = xlsfinfo(filename);
           
%             if ismember('overview',sheets)== 1%check if the excel file contains a sheet named "overview"
%                 overview = table2array(readtable(filename,'Sheet','overview','ReadVariableNames',0));
%                 if exist('overviews') ==1%check if the array exists
%                     overviews = horzcat(overviews,overview);%add the current data to the array
%                 else
%                     overviews=overview;
%                 end
%             end
if ismember('medial_superficial',sheets)== 1
    middle_sup = table2array(readtable(filename,'Sheet','medial_superficial','ReadVariableNames',0));
    if exist('middle_sups') ==1
        middle_sups = horzcat(middle_sups,middle_sup);
    else
        middle_sups=middle_sup;
    end
end
%             if ismember('lateral_mid',sheets)== 1
%                 lateral = table2array(readtable(filename,'Sheet','lateral_mid','ReadVariableNames',0));
%                  if exist('laterals') ==1
%                     laterals = horzcat(laterals,lateral);
%                 else
%                     laterals=lateral;
%                 end
%             end
            if ismember('lateral_deep',sheets)== 1
                lat_cellbodies = table2array(readtable(filename,'Sheet','lateral_deep','ReadVariableNames',0));
                 
                 if exist('lat_cellbodiess') ==1
                    lat_cellbodiess = horzcat(lat_cellbodiess,lat_cellbodies);
                else
                    lat_cellbodiess=lat_cellbodies;
                end
            end
%             if ismember('dorsal_deep',sheets)== 1
%                 dorsal_deep = table2array(readtable(filename,'Sheet','dorsal_deep','ReadVariableNames',0));
%                 if exist('dorsal_deeps') ==1
%                     dorsal_deeps = horzcat(dorsal_deeps,dorsal_deep);
%                 else
%                     dorsal_deeps=dorsal_deep;
%                 end
%             end
%             if ismember('frontal_lateral',sheets)== 1
%                 frontal_lateral = table2array(readtable(filename,'Sheet','frontal_lateral','ReadVariableNames',0));
%                 if exist('frontal_laterals') ==1
%                     frontal_laterals = horzcat(frontal_laterals,frontal_lateral);
%                 else
%                     frontal_laterals=frontal_lateral;
%                 end
%             end
%            if ismember('cellbodies',sheets)== 1
%                 dorsal_sup = table2array(readtable(filename,'Sheet','cellbodies','ReadVariableNames',0));
%                 if exist('dorsal_sups') ==1
%                     dorsal_sups = horzcat(dorsal_sups,dorsal_sup);
%                 else
%                     dorsal_sups=dorsal_sup;
%                 end
%            end
%             if ismember('frontal_deep',sheets)== 1
%                 frontal_deep = table2array(readtable(filename,'Sheet','frontal_deep','ReadVariableNames',0));
%                 if exist('frontal_deeps') ==1
%                     frontal_deeps = horzcat(frontal_deeps,frontal_deep);
%                 else
%                     frontal_deeps=frontal_deep;
%                 end
%             end
%            if ismember('medial_deep',sheets)== 1
%                 middle_deep = table2array(readtable(filename,'Sheet','medial_deep','ReadVariableNames',0));
%                 if exist('middle_deeps') ==1
%                     middle_deeps = horzcat(middle_deeps,middle_deep);
%                 else
%                     middle_deeps=middle_deep;
%                 end
%            end
%             if ismember('lateral_sup',sheets)== 1%check if the excel file contains a sheet named "frontal_sup"
%                 frontal_sup = table2array(readtable(filename,'Sheet','lateral_sup','ReadVariableNames',0));
%                 if exist('frontal_sups') ==1%check if the array exists
%                     frontal_sups = horzcat(frontal_sups,frontal_sup);%add the current data to the array
%                 else
%                     frontal_sups=frontal_sup;
%                 end
%             end
%             if ismember('middle_connection',sheets)== 1
%                 middle_connection = table2array(readtable(filename,'Sheet','middle_connection','ReadVariableNames',0));
%                  if exist('middle_connections') ==1
%                     middle_connections = horzcat(middle_connections,middle_connection);
%                 else
%                     middle_connections=middle_connection;
%                 end
%             end
            
       

         
            filenames(gg,1) = cellstr(filename);
            
        end
        
        outfile=strcat('mean',namestrings(nn,:));%generate the name for the output excel file
        
        if exist('overviews', 'var') == 1
            %write the data to the Excel file
            overview_mean=mean(overviews,2);
            overview_n=size(overviews,2);
            overview_SEM=std(overviews,0,2)/sqrt(overview_n);
            Toverview=table(overview_mean,overview_SEM);
            Tnoverview=table(overview_n);
            writetable(Toverview,outfile,'Sheet','overview','WriteVariableNames',true);
            writetable(Tnoverview,outfile,'Sheet','overview','Range','C1','WriteVariableNames',true);
            %make figure
            newStr = strrep(namestrings(nn,:),'.xlsx','.eps');
            outputfig=strcat('overview',newStr);%make the figure name
            fignew=figure('Name',outputfig);
            %plot the mean with a shaded area showing the SEM
            h=boundedline(x,overview_mean, overview_SEM,'m');
            for numpatch = 1:size(pulsetimes,2)%loop through the number of pulses
                %for each pulse, generate a shaded area in the plot
                %indicating the pulse duration
             hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            %send the shaded area to the back of the graph
             uistack(hpatch(numpatch), 'bottom');
             end
        saveas(fignew,outputfig,'epsc');
        end
        if exist('middle_sups', 'var') == 1
           middle_sup_mean=mean(middle_sups,2);
            middle_sup_n=size(middle_sups,2);
            middle_sup_SEM=std(middle_sups,0,2)/sqrt(middle_sup_n);
            Tmiddle_sup=table(middle_sup_mean,middle_sup_SEM);
            Tnmiddle_sup=table(middle_sup_n);
            writetable(Tmiddle_sup,outfile,'Sheet','medial_superficial','WriteVariableNames',true);
            writetable(Tnmiddle_sup,outfile,'Sheet','medial_superficial','Range','C1','WriteVariableNames',true);
            %make figure
            newStr = strrep(namestrings(nn,:),'.xlsx','.eps');
            outputfig=strcat('medial_superficial',newStr);
            fignew=figure('Name',outputfig);
            h=boundedline(x,middle_sup_mean,middle_sup_SEM,'m');
            for numpatch = 1:size(pulsetimes,2)
             hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
            saveas(fignew,outputfig,'epsc');
        end
        if exist('frontal_sups', 'var') == 1
           frontal_sup_mean=mean(frontal_sups,2);
            frontal_sup_n=size(frontal_sups,2);
            frontal_sup_SEM=std(frontal_sups,0,2)/sqrt(frontal_sup_n);
            Tfrontal_sup=table(frontal_sup_mean,frontal_sup_SEM);
            Tnfrontal_sup=table(frontal_sup_n);
            writetable(Tfrontal_sup,outfile,'Sheet','lateral_sup','WriteVariableNames',true);
            writetable(Tnfrontal_sup,outfile,'Sheet','lateral_sup','Range','C1','WriteVariableNames',true);
            %make figure
            newStr = strrep(namestrings(nn,:),'.xlsx','.eps');
            outputfig=strcat('lateral_sup',newStr);
            fignew=figure('Name',outputfig);
            h=boundedline(x,frontal_sup_mean,frontal_sup_SEM,'m');
            for numpatch = 1:size(pulsetimes,2)
             hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
            saveas(fignew,outputfig,'epsc');
        end
        if exist('laterals', 'var') == 1
           lateral_mean=mean(laterals,2);
            lateral_n=size(laterals,2);
            lateral_SEM=std(laterals,0,2)/sqrt(lateral_n);
            Tlateral=table(lateral_mean,lateral_SEM);
            Tnlateral=table(lateral_n);
            writetable(Tlateral,outfile,'Sheet','lateral_mid','WriteVariableNames',true);
            writetable(Tnlateral,outfile,'Sheet','lateral_mid','Range','C1','WriteVariableNames',true);
        %make figure
            newStr = strrep(namestrings(nn,:),'.xlsx','.eps');
            outputfig=strcat('lateral_mid',newStr);
            fignew=figure('Name',outputfig);
            h=boundedline(x,lateral_mean,lateral_SEM,'m');
            for numpatch = 1:size(pulsetimes,2)
             hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
            saveas(fignew,outputfig,'epsc');
        end
        if exist('lat_cellbodiess', 'var') == 1
           lat_cellbodies_mean=mean(lat_cellbodiess,2);
            lat_cellbodies_n=size(lat_cellbodiess,2);
            lat_cellbodies_SEM=std(lat_cellbodiess,0,2)/sqrt(lat_cellbodies_n);
            Tlat_cellbodies=table(lat_cellbodies_mean,lat_cellbodies_SEM);
            Tnlat_cellbodies=table(lat_cellbodies_n);
            writetable(Tlat_cellbodies,outfile,'Sheet','lateral_deep','WriteVariableNames',true);
            writetable(Tnlat_cellbodies,outfile,'Sheet','lateral_deep','Range','C1','WriteVariableNames',true);
        %make figure
            newStr = strrep(namestrings(nn,:),'.xlsx','.eps');
            outputfig=strcat('lateral_deep',newStr);
            fignew=figure('Name',outputfig);
            h=boundedline(x,lat_cellbodies_mean,lat_cellbodies_SEM,'m');
            for numpatch = 1:size(pulsetimes,2)
             hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
            saveas(fignew,outputfig,'epsc');
        end
        if exist('dorsal_deeps', 'var') == 1
           dorsal_deep_mean=mean(dorsal_deeps,2);
            dorsal_deep_n=size(dorsal_deeps,2);
            dorsal_deep_SEM=std(dorsal_deeps,0,2)/sqrt(dorsal_deep_n);
            Tdorsal_deep=table(dorsal_deep_mean,dorsal_deep_SEM);
            Tndorsal_deep=table(dorsal_deep_n);
            writetable(Tdorsal_deep,outfile,'Sheet','dorsal_deep','WriteVariableNames',true);
            writetable(Tndorsal_deep,outfile,'Sheet','dorsal_deep','Range','C1','WriteVariableNames',true);
        %make figure
            newStr = strrep(namestrings(nn,:),'.xlsx','.eps');
            outputfig=strcat('dorsal_deep',newStr);
            fignew=figure('Name',outputfig);
            h=boundedline(x,dorsal_deep_mean,dorsal_deep_SEM,'m');
            for numpatch = 1:size(pulsetimes,2)
             hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
            saveas(fignew,outputfig,'epsc');
        end
        if exist('frontal_laterals', 'var') == 1
           frontal_lateral_mean=mean(frontal_laterals,2);
            frontal_lateral_n=size(frontal_laterals,2);
            frontal_lateral_SEM=std(frontal_laterals,0,2)/sqrt(frontal_lateral_n);
            Tfrontal_lateral=table(frontal_lateral_mean,frontal_lateral_SEM);
            Tnfrontal_lateral=table(frontal_lateral_n);
            writetable(Tfrontal_lateral,outfile,'Sheet','frontal_lateral','WriteVariableNames',true);
            writetable(Tnfrontal_lateral,outfile,'Sheet','frontal_lateral','Range','C1','WriteVariableNames',true);
        %make figure
            newStr = strrep(namestrings(nn,:),'.xlsx','.eps');
            outputfig=strcat('frontal_lateral',newStr);
            fignew=figure('Name',outputfig);
            h=boundedline(x,frontal_lateral_mean,frontal_lateral_SEM,'m');
            for numpatch = 1:size(pulsetimes,2)
             hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
            saveas(fignew,outputfig,'epsc');
        end
        if exist('dorsal_sups', 'var') == 1
           dorsal_sup_mean=mean(dorsal_sups,2);
            dorsal_sup_n=size(dorsal_sups,2);
            dorsal_sup_SEM=std(dorsal_sups,0,2)/sqrt(dorsal_sup_n);
            Tdorsal_sup=table(dorsal_sup_mean,dorsal_sup_SEM);
            Tndorsal_sup=table(dorsal_sup_n);
            writetable(Tdorsal_sup,outfile,'Sheet','cellbodies','WriteVariableNames',true);
            writetable(Tndorsal_sup,outfile,'Sheet','cellbodies','Range','C1','WriteVariableNames',true);
        %make figure
            newStr = strrep(namestrings(nn,:),'.xlsx','.eps');
            outputfig=strcat('cellbodies',newStr);
            fignew=figure('Name',outputfig);
            h=boundedline(x,dorsal_sup_mean,dorsal_sup_SEM,'m');
            for numpatch = 1:size(pulsetimes,2)
             hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
            saveas(fignew,outputfig,'epsc');
        end
        if exist('frontal_deeps', 'var') == 1
           frontal_deep_mean=mean(frontal_deeps,2);
            frontal_deep_n=size(frontal_deeps,2);
            frontal_deep_SEM=std(frontal_deeps,0,2)/sqrt(frontal_deep_n);
            Tfrontal_deep=table(frontal_deep_mean,frontal_deep_SEM);
            Tnfrontal_deep=table(frontal_deep_n);
            writetable(Tfrontal_deep,outfile,'Sheet','frontal_deep','WriteVariableNames',true);
            writetable(Tnfrontal_deep,outfile,'Sheet','frontal_deep','Range','C1','WriteVariableNames',true);
        %make figure
            newStr = strrep(namestrings(nn,:),'.xlsx','.eps');
            outputfig=strcat('frontal_deep',newStr);
            fignew=figure('Name',outputfig);
            h=boundedline(x,frontal_deep_mean,frontal_deep_SEM,'m');
            for numpatch = 1:size(pulsetimes,2)
             hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
            saveas(fignew,outputfig,'epsc');
        end
        if exist('middle_deeps', 'var') == 1
           middle_deep_mean=mean(middle_deeps,2);
            middle_deep_n=size(middle_deeps,2);
            middle_deep_SEM=std(middle_deeps,0,2)/sqrt(middle_deep_n);
            Tmiddle_deep=table(middle_deep_mean,middle_deep_SEM);
            Tnmiddle_deep=table(middle_deep_n);
            writetable(Tmiddle_deep,outfile,'Sheet','medial_deep','WriteVariableNames',true);
            writetable(Tnmiddle_deep,outfile,'Sheet','medial_deep','Range','C1','WriteVariableNames',true);
        %make figure
            newStr = strrep(namestrings(nn,:),'.xlsx','.eps');
            outputfig=strcat('medial_deep',newStr);
            fignew=figure('Name',outputfig);
            h=boundedline(x,middle_deep_mean,middle_deep_SEM,'m');
            for numpatch = 1:size(pulsetimes,2)
             hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
            saveas(fignew,outputfig,'epsc');
        end
        if exist('middle_connections', 'var') == 1
           middle_connection_mean=mean(middle_connections,2);
            middle_connection_n=size(middle_connections,2);
            middle_connection_SEM=std(middle_connections,0,2)/sqrt(middle_connection_n);
            Tmiddle_connection=table(middle_connection_mean,middle_connection_SEM);
            Tnmiddle_connection=table(middle_connection_n);
            writetable(Tmiddle_connection,outfile,'Sheet','middle_connection','WriteVariableNames',true);
            writetable(Tnmiddle_connection,outfile,'Sheet','middle_connection','Range','C1','WriteVariableNames',true);
        %make figure
            newStr = strrep(namestrings(nn,:),'.xlsx','.eps');
            outputfig=strcat('middle_connection',newStr);
            fignew=figure('Name',outputfig);
            h=boundedline(x,middle_connection_mean,middle_connection_SEM,'m');
            for numpatch = 1:size(pulsetimes,2)
             hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
            saveas(fignew,outputfig,'epsc');
        end
        clearvars middle_connections middle_deeps frontal_deeps dorsal_sups frontal_laterals dorsal_deeps lat_cellbodiess laterals frontal_sups middle_sups overviews 
end
        
        
        %go back to directory of matlab scripts
        cd(startdir);



