%Annika Rings January 2019
%ALIGN_TOUCHES: is a function for reading in touchtimes files from specified 'touchdir' directory
%It then reads in corresponding imaging results F from another
%directory specified as 'resultsdir'
%Touch events are defined 
%for each touch event, corresponding fluorescence data are found. The
%events are aligned. They are then averaged per experiment and experiment
%results are averaged for each species.
%they are plotted separately for male, virgin female and mated female experimental flies.
%they are expected to contain the following strings in the filenames for
%recognition:
%'_male_fly': for experimental male
%'_female_fly': for experimental virgin female
%'matedF_fly': for mated female experimental flies

%reduced touchtimes are supported: only the start and the end of each touch
%period are specified on the excel table
%alternative: specify all touch frames
%use of reduced touchtimes option requires the name of touch directory to
%contain the string 'reduced'
%the otpional 'reduced' keyword argument can also be used to specify
%whether the reduced or complete touchtimes format was used by setting
%'reduced' to either true or false. This overrides determining the
%touchtimes format by directory name and can be used independent of the directory
%name
%takes no required arguments
%optional arguments are:
%framerate: in Hz, default: 5.92
%numframes: number of frames in imaging, default: 600
% touchdir: The folder where the touchtimes files are located
% resultsdir :The folder where the results of single experiments are located
% outputdirmean: output directory for average
% outputdirsingles:outputdirectory for single experiment plots (disabled at
% the moment)
%basetime: length of baseline, default: 10s
%eventtime: length of an event (after the touch), default: 20s
%intervaltime: length of minimum interval between touches, default: 10s
%excludedoubles: whether touches on both sides in a short timeperiod should
%be excluded. Default: false 
% filterstring = 'medial_superficial'; % a string by which exps should be filtered
%this can be a specific part of the neuron imaged form
%dependencies: 
%-options_resolver.m
%-boundedline.m

function align_touches(varargin)
options = struct('framerate',5.92,'numframes',600,'touchdir','touchtimes','resultsdir','Results','outputdirmean','Results','outputdir_singles','Results_single_exp','basetime',10,'eventtime',20,'intervaltime',10,'excludedoubles',0,'filterstring','','reduced',false);
arguments = varargin;

%call the options_resolver function to check optional key-value pair
%arguments
[options,override_reduced]=options_resolver(options,arguments,'align_touches');
%setting the values for optional arguments
framerate = options.framerate;
numframes = options.numframes;
touchdir = options.touchdir;
resultsdir = options.resultsdir;
outputdirmean=options.outputdirmean;
reduced = options.reduced;
intervaltime = options.intervaltime;
basetime=options.basetime;
eventtime = options.eventtime;
excludedoubles=options.excludedoubles;
filterstring=options.filterstring;

%This part of the script reads in the data
currentdir = pwd;
lateralized = 0;
if contains (touchdir, '_l_r_')
    lateralized = 1;
end
if contains (touchdir, '_r_l_')
    lateralized = 1;
end
options.lateralized=lateralized;
if ~override_reduced
    if contains (touchdir, 'reduced')
        reduced =1;
    else
        reduced =0;
    end
end

%go to touchdirectory
cd(touchdir)
%get filenames form the directory
files = dir('*.xlsx');

files = {files.name};
%read in all the touchtimes from the files
touchtimes=cellfun(@(filename) table2array(readtable(filename,'Range','E:E','ReadVariableNames',1)), files, 'UniformOutput', false);
if lateralized
    touchtimes_r=cellfun(@(filename) table2array(readtable(filename,'Range','I:I','ReadVariableNames',1)), files, 'UniformOutput', false);
else
    touchtimes_r = touchtimes;
end
if reduced
    disp ('reduced touchtime format was used.');
    touchtimes=cellfun(@(testtimes) expand_reduced_touchtimes(testtimes),touchtimes,'UniformOutput',false);
    touchtimes_r=cellfun(@(testtimes) expand_reduced_touchtimes(testtimes),touchtimes_r,'UniformOutput',false);
    
end

%touchtimes(cellfun ('isempty', touchtimes)) ={[0;0]};
resultfilestrings=cellfun(@(filename) strrep((regexprep(filename,'_(\d+).xlsx','_')),'touchtimes_',''), files, 'UniformOutput', false);
numberstrings=cellfun(@(filename) strrep((regexprep(filename,'touchtimes_(\d+)_(\d+)_(\d+)_','')),'.xlsx',''), files, 'UniformOutput', false);
cd (currentdir);
cd(resultsdir);
resultfiles = cellfun(@(resultfilestring) dir(strcat(resultfilestring,'*.xlsx')), resultfilestrings, 'UniformOutput', false);
resultfiles = cellfun(@(resultfile) {resultfile.name}, resultfiles, 'UniformOutput', false);

resultfilenames=cellfun(@(resultfile) resultfile, {resultfiles}, 'UniformOutput', false);
expnames=cellfun(@(resultfile) cellfun(@(resultf) table2array(readtable(resultf,'Sheet','Sheet2','ReadVariableNames',0)), resultfile, 'UniformOutput', false), resultfiles, 'UniformOutput', false);
foundstr=cellfun(@(numbers,files) cellfun(@(resultsfiles) cellfun(@(exp) contains(exp,numbers),resultsfiles), files,'UniformOutput', false),numberstrings, expnames, 'UniformOutput', false);
[found]=cellfun(@(numbers,files) cellfun(@(resultsfiles) cellfun(@(exp) foundstringnames(exp,numbers),resultsfiles, 'Uniformoutput', false), files,'UniformOutput', false),numberstrings, expnames, 'UniformOutput', false);
[foundin,foundfilename,fileindex]= cellfun(@(exps,nums,rfiles) findfounds2(exps,nums,rfiles), expnames, numberstrings,resultfiles,'UniformOutput',false);

imagingfilestrings=foundfilename;

all_expresults=cellfun(@(foundname,foundindex) resultfinder(foundname,foundindex{1,1}), foundin,fileindex,'UniformOutput',false);

data_array=cellfun(@(data1,data2,filename,resultname,data3) {transpose(data1),transpose(data2),transpose(filename),transpose(resultname),transpose(data3)}, touchtimes, all_expresults,foundfilename,foundin,touchtimes_r,'UniformOutput', false);
data_array=transpose(data_array);
data_array_swapped=cellfun(@(data1,data2,filename,resultname,data3) {transpose(data1),transpose(data2),transpose(filename),transpose(resultname),transpose(data3)}, touchtimes_r, all_expresults,foundfilename,foundin,touchtimes,'UniformOutput', false);
data_array_swapped=transpose(data_array_swapped);




%This part of the script defines the events, aligns them and performs the
%calculations
[touchstartframes,eventsmat,eventpeaks,eventpeaks_mean,eventpeaks_SEM,mean_event,SEM_event,touchtimes,fluo,x_events]= cellfun(@(data_arr) find_touch_events(data_arr,options), data_array, 'UniformOutput', false);
[touchstartframes_contra,eventsmat_contra,eventpeaks_contra,eventpeaks_mean_contra,eventpeaks_SEM_contra,mean_event_contra,SEM_event_contra,touchtimes_contra,fluo_contra,x_events_contra]= cellfun(@(data_arr) find_touch_events(data_arr,options), data_array_swapped, 'UniformOutput', false);

t_foundfilename=transpose(foundfilename);
t_foundin=transpose(foundin);

eventpeaks_mean = cellfun(@(ev) standardizeMissing(ev,0),eventpeaks_mean);
eventpeaks_mean=standardizeMissing(eventpeaks_mean,Inf);
mean_event = cellfun(@(ev) standardizeMissing(ev,0),mean_event, 'uni',false);
eventsmat = cellfun(@(ev) standardizeMissing(ev,0),eventsmat,'uni',false);

eventpeaks_mean_contra = cellfun(@(ev) standardizeMissing(ev,0),eventpeaks_mean_contra);
mean_event_contra = cellfun(@(ev) standardizeMissing(ev,0),mean_event_contra, 'uni',false);
eventsmat_contra = cellfun(@(ev) standardizeMissing(ev,0),eventsmat_contra,'uni',false);

average_event=cellfun(@(foundinfilename,foundinfile) average_within_fly(foundfilename,foundin,eventsmat,foundinfilename{1},foundinfile),foundfilename,foundin,'uni',false);
average_event_contra=cellfun(@(foundinfilename,foundinfile) average_within_fly(foundfilename,foundin,eventsmat_contra,foundinfilename{1},foundinfile),foundfilename,foundin,'uni',false);
%This part of the script averages over the experiments of each species type
average2mat=transpose(cell2mat(average_event));
average2mat_contra=transpose(cell2mat(average_event_contra));

combinedtable_unfiltered=table(eventpeaks_mean, mean_event, t_foundfilename,t_foundin,eventsmat,average2mat);
combinedtable_contra_unfiltered=table(eventpeaks_mean_contra, mean_event_contra, t_foundfilename,t_foundin,eventsmat_contra,average2mat_contra);
%find the male experimental flies
combinedtable = combinedtable_unfiltered( contains(string(combinedtable_unfiltered.t_foundfilename),filterstring), : );
combinedtable_contra = combinedtable_contra_unfiltered( contains(string(combinedtable_contra_unfiltered.t_foundfilename),filterstring), : );
%combinedtable=standardizeMissing(combinedtable,{0});
combinedtable = rmmissing(combinedtable);
%combinedtable_contra=standardizeMissing(combinedtable_contra,{0});unique
combinedtable_contra = rmmissing(combinedtable_contra);
combinedtable_male = combinedtable( contains(string(combinedtable.t_foundfilename),'_male_fly'), : );

combinedtable_male_contra = combinedtable_contra( contains(string(combinedtable_contra.t_foundfilename),'_male_fly'), : );
%extract the different species from the table

%for ipsilateral touchts

maletable_m = combinedtable_male( contains(string(combinedtable_male.t_foundin),''), : );

%contralateral touches

maletable_m_contra = combinedtable_male_contra( contains(string(combinedtable_male_contra.t_foundin),''), : );


%convert the tables to cell arrays
%ipsi

maledata_m=table2cell(maletable_m);

%contra


maledata_m_contra=table2cell(maletable_m_contra);







%mean of male touching  male



male_eventpeaks_mean_m=mean(maletable_m.eventpeaks_mean);
male_eventpeaks_SEM_m=std(maletable_m.eventpeaks_mean)/sqrt(size(maletable_m.eventpeaks_mean,1));


cell_mean_event_m=transpose(rmmissing(unique(maletable_m.average2mat,'rows')));

male_mean_event_m=mean(cell_mean_event_m,2);
male_SEM_event_m=std(cell_mean_event_m,0,2)/sqrt(size(cell_mean_event_m,2));

cell_mean_event_m_contra=transpose(rmmissing(unique(maletable_m_contra.average2mat_contra,'rows')));
male_mean_event_m_contra=mean(cell_mean_event_m_contra,2);
male_SEM_event_m_contra=std(cell_mean_event_m_contra,0,2)/sqrt(size(cell_mean_event_m_contra,2));




%find the female experimental flies

combinedtable_female = combinedtable( contains(string(combinedtable.t_foundfilename),'_female_fly'), : );
combinedtable_female_contra = combinedtable_contra( contains(string(combinedtable_contra.t_foundfilename),'_female_fly'), : );


maletable_f = combinedtable_female( contains(string(combinedtable_female.t_foundin),''), : );

%contralateral touches

maletable_f_contra = combinedtable_female_contra( contains(string(combinedtable_female_contra.t_foundin),''), : );


%convert the tables to cell arrays
%ipsi



maledata_f=table2cell(maletable_f);


%contra


maledata_f_contra=table2cell(maletable_f_contra);




%mean of female exp flies



male_eventpeaks_mean_f=mean(maletable_f.eventpeaks_mean);
male_eventpeaks_SEM_f=std(maletable_f.eventpeaks_mean)/sqrt(size(maletable_f.eventpeaks_mean,1));

cell_mean_event_f=transpose(rmmissing(unique(maletable_f.average2mat,'rows')));

male_mean_event_f=mean(cell_mean_event_f,2);
male_SEM_event_f=std(cell_mean_event_f,0,2)/sqrt(size(cell_mean_event_f,2));
cell_mean_event_f_contra=transpose(rmmissing(unique(maletable_f_contra.average2mat_contra,'rows')));
male_mean_event_f_contra=mean(cell_mean_event_f_contra,2);
male_SEM_event_f_contra=std(cell_mean_event_f_contra,0,2)/sqrt(size(cell_mean_event_f_contra,2));





%find the mated female experimental flies

combinedtable_mfemale = combinedtable( contains(string(combinedtable.t_foundfilename),'_matedF_fly'), : );
combinedtable_mfemale_contra = combinedtable_contra( contains(string(combinedtable_contra.t_foundfilename),'_matedF_fly'), : );


maletable_mf = combinedtable_mfemale( contains(string(combinedtable_mfemale.t_foundin),''), : );

%contralateral touches

maletable_mf_contra = combinedtable_mfemale_contra( contains(string(combinedtable_mfemale_contra.t_foundin),''), : );


%convert the tables to cell arrays
%ipsi


maledata_mf=table2cell(maletable_mf);

%contra


maledata_mf_contra=table2cell(maletable_mf_contra);



%mean of mated female touching



male_eventpeaks_mean_mf=mean(maletable_mf.eventpeaks_mean);
male_eventpeaks_SEM_mf=std(maletable_mf.eventpeaks_mean)/sqrt(size(maletable_mf.eventpeaks_mean,1));

cell_mean_event_mf=transpose(rmmissing(unique(maletable_mf.average2mat,'rows')));
male_mean_event_mf=mean(cell_mean_event_mf,2);
male_SEM_event_mf=std(cell_mean_event_mf,0,2)/sqrt(size(cell_mean_event_mf,2));
cell_mean_event_mf_contra=transpose(rmmissing(unique(maletable_mf_contra.average2mat_contra,'rows')));%changed for debugging
male_mean_event_mf_contra=mean(cell_mean_event_mf_contra,2);
male_SEM_event_mf_contra=std(cell_mean_event_mf_contra,0,2)/sqrt(size(cell_mean_event_mf_contra,2));









xevents_nonempty=x_events( ~cellfun(@(cell) isempty (cell),x_events));
xevents_nonempty_contra=x_events_contra( ~cellfun(@(cell) isempty (cell),x_events_contra));
cd (currentdir);






%plot the mean event of male
%------------------------------
%-------------------------------

if lateralized
try
    fignew=figure('Name','male_mean_event_ipsi');
    %requires package boundedline
    plot_male_event_m=boundedline(xevents_nonempty{1,1},male_mean_event_m,male_SEM_event_m,'m');
    cd(outputdirmean);
    saveas(fignew,'male_mean_event_ipsi','epsc');
    save('mean_male_touch_ipsi.mat','male_mean_event_m','male_SEM_event_m');
    
catch ME
    errorMessage = ME.message;
    disp(errorMessage);
end
cd (currentdir);
try
    fignew=figure('Name','male_mean_event_contra');
    %requires package boundedline
    plot_male_event_m_contra=boundedline(xevents_nonempty_contra{1,1},male_mean_event_m_contra,male_SEM_event_m_contra,'m');
    cd(outputdirmean);
    saveas(fignew,'male_mean_event_contra','epsc');
    save('mean_male_touch_contra.mat','male_mean_event_m_contra','male_SEM_event_m_contra');
    
catch ME
    errorMessage = ME.message;
    disp(errorMessage);
end

cd (currentdir);
try
    fignew=figure('Name','female_mean_event_ipsi');
    %requires package boundedline
    plot_male_event_f=boundedline(xevents_nonempty{1,1},male_mean_event_f,male_SEM_event_f,'m');
    
    cd(outputdirmean);
    saveas(fignew,'female_mean_event_ipsi','epsc');
    save('mean_female_touch_ipsi.mat','male_mean_event_f','male_SEM_event_f');
    
    
catch ME
    errorMessage = ME.message;
    disp(errorMessage);
end
cd (currentdir);
try
    fignew=figure('Name','female_mean_event_contra');
    %requires package boundedline
    plot_male_event_f_contra=boundedline(xevents_nonempty_contra{1,1},male_mean_event_f_contra,male_SEM_event_f_contra,'m');
    
    cd(outputdirmean);
    saveas(fignew,'female_mean_event_contra','epsc');
    save('mean_female_touch_contra.mat','male_mean_event_f_contra','male_SEM_event_f_contra');
    
catch ME
    errorMessage = ME.message;
    disp(errorMessage);
end

cd (currentdir);
try
    fignew=figure('Name','mated_female_mean_event_ipsi');
    %requires package boundedline
    plot_male_event_mf=boundedline(xevents_nonempty{1,1},male_mean_event_mf,male_SEM_event_mf,'m');
    
    cd(outputdirmean);
    saveas(fignew,'mated_female_mean_event_ipsi','epsc');
    save('mean_mated_female_touch_ipsi.mat','male_mean_event_mf','male_SEM_event_mf');
    
    
catch ME
    errorMessage = ME.message;
    disp(errorMessage);
end
cd (currentdir);
try
    fignew=figure('Name','mated_female_mean_event_contra');
    %requires package boundedline
    plot_male_event_mf_contra=boundedline(xevents_nonempty_contra{1,1},male_mean_event_mf_contra,male_SEM_event_mf_contra,'m');
    
    cd(outputdirmean);
    saveas(fignew,'mated_female_mean_event_contra','epsc');
    save('mean_mated_female_touch_contra.mat','male_mean_event_mf_contra','male_SEM_event_mf_contra');
    
catch ME
    errorMessage = ME.message;
    disp(errorMessage);
end

else
    
try
    fignew=figure('Name','male_mean_event');
    %requires package boundedline
    plot_male_event_m=boundedline(xevents_nonempty{1,1},male_mean_event_m,male_SEM_event_m,'m');
    cd(outputdirmean);
    saveas(fignew,'male_mean_event','epsc');
    save('mean_male_touch.mat','male_mean_event_m','male_SEM_event_m');
    
catch ME
    errorMessage = ME.message;
    disp(errorMessage);
end
cd (currentdir);

try
    fignew=figure('Name','female_mean_event');
    %requires package boundedline
    plot_male_event_f=boundedline(xevents_nonempty{1,1},male_mean_event_f,male_SEM_event_f,'m');
    
    cd(outputdirmean);
    saveas(fignew,'female_mean_event','epsc');
    save('mean_female_touch.mat','male_mean_event_f','male_SEM_event_f');
    
    
catch ME
    errorMessage = ME.message;
    disp(errorMessage);
end
cd (currentdir);



try
    fignew=figure('Name','mated_female_mean_event');
    %requires package boundedline
    plot_male_event_mf=boundedline(xevents_nonempty{1,1},male_mean_event_mf,male_SEM_event_mf,'m');
    
    cd(outputdirmean);
    saveas(fignew,'mated_female_mean_event','epsc');
    save('mean_mated_female_touch.mat','male_mean_event_mf','male_SEM_event_mf');
    
    
catch ME
    errorMessage = ME.message;
    disp(errorMessage);
end
cd (currentdir);
end
try
    cd(outputdirmean);
    save('x_events.mat','xevents_nonempty{1,1}');
catch ME
    errorMessage = ME.message;
    disp(errorMessage);
end
cd (currentdir);
end

%This part is the definition of the functions used in the previous parts of
%the script.

function [touchstartframes,eventsmat,eventpeaks,eventpeaks_mean,eventpeaks_SEM,mean_event,SEM_event,touchtimes,fluo,x_events] = find_touch_events(data,options)
framerate = options.framerate;
numframes = options.numframes;
touchdir = options.touchdir;
resultsdir = options.resultsdir;
outputdirmean=options.outputdirmean;
reduced = options.reduced;
intervaltime = options.intervaltime;
basetime=options.basetime;
eventtime = options.eventtime;
excludedoubles=options.excludedoubles;
filterstring=options.filterstring;
lateralized = options.lateralized;

if lateralized
    if contains(string(data{3}),'(r)')
        disp('imaged right side');
        touchtimes=data{5};
        
        touch_other_side=data{1};
        
    else
        disp('imaged left side');
        touchtimes=data{1};
        
        touch_other_side=data{5};
        
    end
else
    touchtimes=data{1};
    
    touch_other_side=data{5};
    
end

fluo=data{2};
outputfig=(data{3});
%time for calculating the baseline before each touch

%shift the matrix to the right by one
%framerate of imaging to be entered here
if isnan(touchtimes)
    touchstartframes=0;
    eventsmat=0';
    eventpeaks=0;
    eventpeaks_mean=0';
    eventpeaks_SEM=0;
    mean_event=0;
    SEM_event=0;
    x_events=0;
else
    
    touchtimes_shifted=circshift(touchtimes,[0,1]);
    touchtimes_shifted(1)=0;
    %subtract the shifted matrix from the original one (corresponds to
    %substracting the previous element from each element
    intervals=touchtimes-touchtimes_shifted;
    %find intervals of more than intervaltime between the touches (output type is
    %logical)
    starts=intervals>=intervaltime;
    %find starttimes of the touchevents
    starttimes=starts.*touchtimes;%This contains zeros for all spaces in the matrix that are not starts of touch events
    
    endtime_intervals=((numframes-1)/framerate)-touchtimes;
    
    %find out if event starts at least 'eventtime' before end of recording (output type is
    %logical)
    ends_on_time=endtime_intervals>=eventtime+(1/framerate);
    %find starttimes of the touchevents
    starttimes=ends_on_time.*starttimes;%This contains zeros for all spaces in the matrix that do not end on time
    %disp(starttimes);
    if excludedoubles
        tfarray=arrayfun(@(time) (~doubletouch(time,intervaltime,eventtime,touch_other_side)),starttimes);
        starttimes=tfarray.*starttimes;%This contains zeros for all spaces in the matrix that overlap with a touch from the contralateral side
    end
    touchstarts=rmmissing(nonzeros(starttimes));%reduce matrix to contain only starts
    %calculate the frame number from the time of the touchstarts
    touchstartframes=round(touchstarts*framerate);
    
    %calculate the timepoints
    x=1:numframes;
    x=x/framerate; %changed to make frame one start at time 1/framerate instead of time 0 due to time required for laser scanning
    
    
    
    %this defines events and saves them to a cell array called events
    %the events are defined as the fluorescence trace starting at basetime
    %before touchstart and ending at touchstart + eventtime
    events=arrayfun(@(touchstart) fluo(touchstart-(ceil(basetime*framerate)):touchstart+(floor(eventtime*framerate))), touchstartframes,'UniformOutput',false);
    %convert cell array events to a matrix - necessary for subsequent
    %calculations
    %[eventsmat, event]=makemyevents(events);
    events=transpose(events);
    eventsmat=cell2mat(transpose(events));
    eventsmat=transpose(eventsmat);
    %average all events frame by frame (after aligning them to the start of the
    %touch event)
    if isempty(eventsmat)==0
        
        eventbases1=mean(eventsmat((1:round(basetime*framerate)+1),:));
        %calculate dF/F using the baseline from the events in eventsmat
        eventsmat=(eventsmat-eventbases1)./eventbases1;
        
        
    else
        
    end
    mean_event=mean(eventsmat,2);
    %SEM for each point in the averaged event
    SEM_event=std(eventsmat,0,2)/sqrt(size(eventsmat,2));
    %calculate single peak of each event during eventtime
    %first_touch_event=eventsmat(:,1);
    eventpeaks=transpose(max(eventsmat((round(basetime*framerate)+1:size(eventsmat,1)),:)));
    % baseline for each event before the touch
    if isempty(eventsmat)==0
        eventbases=transpose(mean(eventsmat((1:round(basetime*framerate)+1),:)));
        
        %calculate deltaF/F for that event
        
        eventpeaks_dff=(eventpeaks-eventbases)./eventbases;
    else
        eventpeaks_dff=0;
    end
    
    %calculate the mean of the peaks of single events
    eventpeaks_mean=mean(eventpeaks_dff);
    eventpeaks_SEM=std(eventpeaks_dff,0,1)/sqrt(size(eventpeaks_dff,1));
    %make the x (timepoints) for the events - times are relative to the onset
    %of the touch
    x_events=transpose(x(1:length(mean_event))-basetime);
    
    
    
end
end


function [foundexp]= foundstringnames(expname,numberstring)
if contains(expname,numberstring) == 1
    
    foundexp = expname;
    
    
else
    foundexp = [];
end


end
function [ffounds,index]=findfounds(exparray,numbarray)
ffounds=cellfun(@(exp) foundstringnames(exp,numbarray), exparray,'UniformOutput',false);

index=find(~cellfun('isempty',ffounds));
ffounds=ffounds(~cellfun('isempty',ffounds));

end
function [foundinfiles,fffounds,iindex]=findfounds2(resultsarray,numbarray,rresultfilenames)
[fffounds,iindex]=cellfun(@(resultsfiles) findfounds(resultsfiles,numbarray), resultsarray,'UniformOutput', false);
%foundinfiles={};
for i=1:length(resultsarray)
    if isempty(fffounds{i})==1
        foundinfiles{i}={};
    else
        
        foundinfiles{i}=rresultfilenames{i};
    end
end
fffounds=fffounds(~cellfun('isempty',fffounds));
foundinfiles=foundinfiles(~cellfun('isempty',foundinfiles));
iindex=iindex(~cellfun('isempty',iindex));



end
function[singleresult]=resultfinder(nameoffile,indexoffile)

expresults =table2array(readtable(char(nameoffile),'Sheet','Sheet1','ReadVariableNames',0));
singleresult=expresults(:,indexoffile);

end

function[outputtimes]=expand_reduced_touchtimes(testtimes)
outputtimes=[];

for i=1:2:length(testtimes)-1
    
    
    for j=0:round(testtimes(i+1)-testtimes(i))
        outputtimes=[outputtimes;(testtimes(i)+j)];
    end
    
end
end

function tf=doubletouch(touchtime,interval,dur,touchtimes_other_side)
tf=any((touchtime-interval)<touchtimes_other_side&touchtimes_other_side<(touchtime+dur));
end

function average_event=average_within_fly(foundfilenamearr,foundinarr,eventsmatarr,filename,foundinfilename)
flynumb = regexp(filename{1},"fly\d+_",'match');
sames = cellfun(@(foundfilename,foundin1) (contains(foundfilename{1}{1},flynumb{1}) && (string(foundin1{1})==string(foundinfilename))), foundfilenamearr,foundinarr);
total_eventsmat=eventsmatarr(sames);
eventsmat_new=horzcat(total_eventsmat{:});
average_event=mean(eventsmat_new,2);
end