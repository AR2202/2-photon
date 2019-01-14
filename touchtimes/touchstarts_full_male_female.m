%Annika Rings January 2019
%This is a script for reading in touchtimes files from a directory
%It then reads in corresponding imaging results F from another
%directory
%Touch events are defined 
%for each touch event, corresponding fluorescence data are found. The
%events are aligned. They are then averaged per experiment and experiment
%results are averaged for each species.
%they are plotted separately for male and female experimental flies.
%they are expected to contain the following strings in the filenames for
%recognition:
%'_male_fly': for experimental male
%'_female_fly': for experimental female
%'male': for a male target
%'vir': for a virgin female target

%reduced touchtimes are supported: only the start and the end of each touch
%period are specified on the excel table
%alternative: specify all touch frames
%use of reduced touchtimes option requires the name of touch directory to
%contain the string 'reduced'

touchdir = ('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/aDN_female_male_touch/touch_medial_reduced');
% The folder where the touchtimes files are located
resultsdir = ('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/aDN_female_male_touch/Results');
% The folder where the results of single experiments are located
outputdirmean=('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/aDN_female_male_touch/Results_mean');
outputdirsingles=('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/aDN_female_male_touch/Results_single_exp');
%The folder where the mean data should be written to

%This part of the script reads in the data

reduced=0;
if contains (touchdir, 'reduced')
    reduced =1;
end

%go to touchdirectory
cd(touchdir)
%get filenames form the directory
files = dir('*.xlsx');

files = {files.name};
%read in all the touchtimes from the files
touchtimes=cellfun(@(filename) table2array(readtable(filename,'Range','E:E','ReadVariableNames',1)), files, 'UniformOutput', false);
if reduced
    disp ('reduced touchtime format was used.');
    touchtimes=cellfun(@(testtimes) expand_reduced_touchtimes(testtimes),touchtimes,'UniformOutput',false);
end
resultfilestrings=cellfun(@(filename) strrep((regexprep(filename,'_(\d+).xlsx','_')),'touchtimes_',''), files, 'UniformOutput', false);
numberstrings=cellfun(@(filename) strrep((regexprep(filename,'touchtimes_(\d+)_(\d+)_(\d+)_','')),'.xlsx',''), files, 'UniformOutput', false);
               
cd(resultsdir);
resultfiles = cellfun(@(resultfilestring) dir(strcat(resultfilestring,'*.xlsx')), resultfilestrings, 'UniformOutput', false);
resultfiles = cellfun(@(resultfile) {resultfile.name}, resultfiles, 'UniformOutput', false);

resultfilenames=cellfun(@(resultfile) resultfile, {resultfiles}, 'UniformOutput', false);
expnames=cellfun(@(resultfile) cellfun(@(resultf) table2array(readtable(resultf,'Sheet','Sheet2','ReadVariableNames',0)), resultfile, 'UniformOutput', false), resultfiles, 'UniformOutput', false);
foundstr=cellfun(@(numbers,files) cellfun(@(resultsfiles) cellfun(@(exp) contains(exp,numbers),resultsfiles), files,'UniformOutput', false),numberstrings, expnames, 'UniformOutput', false);
[found]=cellfun(@(numbers,files) cellfun(@(resultsfiles) cellfun(@(exp) foundstringnames(exp,numbers),resultsfiles, 'Uniformoutput', false), files,'UniformOutput', false),numberstrings, expnames, 'UniformOutput', false);
[foundin,foundfilename,fileindex]= cellfun(@(exps,nums,rfiles) findfounds2(exps,nums,rfiles), expnames, numberstrings,resultfiles,'UniformOutput',false);
 
  imagingfilestrings=string(foundfilename);
 
 all_expresults=cellfun(@(foundname,foundindex) resultfinder(string(foundname),foundindex{1,1}), foundin,fileindex,'UniformOutput',false);
  
 data_array=cellfun(@(data1,data2,filename,resultname) {transpose(data1),transpose(data2),transpose(filename),transpose(resultname)}, touchtimes, all_expresults,foundfilename,foundin,'UniformOutput', false);  
 data_array=transpose(data_array);                  





%This part of the script defines the events, aligns them and performs the
%calculations
[touchstartframes,eventsmat,eventpeaks,eventpeaks_mean,eventpeaks_SEM,mean_event,SEM_event,touchtimes,fluo,x_events,first_touch_events]= cellfun(@(data_arr) find_touch_events(data_arr), data_array, 'UniformOutput', false);

t_foundfilename=transpose(foundfilename);
t_foundin=transpose(foundin);

%This part of the script averages over the experiments of each species type

combinedtable=table(eventpeaks_mean, mean_event, t_foundfilename,t_foundin,eventsmat,first_touch_events);
%find the male experimental flies

combinedtable_male = combinedtable( contains(string(combinedtable.t_foundfilename),'_male_fly'), : ); 
%extract the different species from the table

simtable_m = combinedtable_male( contains(string(combinedtable_male.t_foundin),'simulans'), : ); 
yaktable_m = combinedtable_male( contains(string(combinedtable_male.t_foundin),'yakuba'), : ); 
virtable_m = combinedtable_male( contains(string(combinedtable_male.t_foundin),'vir'), : ); 
maletable_m = combinedtable_male( contains(string(combinedtable_male.t_foundin),'male'), : ); 
simdata_m=table2cell(simtable_m);
yakdata_m=table2cell(yaktable_m);
virdata_m=table2cell(virtable_m);
maledata_m=table2cell(maletable_m);
%mean of virgin
 
vir_eventpeaks_mean_m=mean(cell2mat(virtable_m.eventpeaks_mean));
vir_eventpeaks_SEM=std(cell2mat(virtable_m.eventpeaks_mean))/sqrt(size(cell2mat(virtable_m.eventpeaks_mean),1));

cell_mean_event_m=cell2mat(transpose(virtable_m.mean_event(~cellfun(@isempty, virtable_m.mean_event))));

vir_mean_event_m=mean(cell_mean_event_m,2);
vir_SEM_event_m=std(cell_mean_event_m,0,2)/sqrt(size(cell_mean_event_m,2));


%mean of male

 
 
male_eventpeaks_mean_m=mean(cell2mat(maletable_m.eventpeaks_mean));
male_eventpeaks_SEM_m=std(cell2mat(maletable_m.eventpeaks_mean))/sqrt(size(cell2mat(maletable_m.eventpeaks_mean),1));

cell_mean_event_m=cell2mat(transpose(maletable_m.mean_event(~cellfun(@isempty, maletable_m.mean_event))));

male_mean_event_m=mean(cell_mean_event_m,2);
male_SEM_event_m=std(cell_mean_event_m,0,2)/sqrt(size(cell_mean_event_m,2));

%find the female experimental flies

combinedtable_female = combinedtable( contains(string(combinedtable.t_foundfilename),'_female_fly'), : ); 

simtable_f = combinedtable_female( contains(string(combinedtable_female.t_foundin),'simulans'), : ); 
yaktable_f = combinedtable_female( contains(string(combinedtable_female.t_foundin),'yakuba'), : ); 
virtable_f = combinedtable_female( contains(string(combinedtable_female.t_foundin),'vir'), : ); 
maletable_f = combinedtable_female( contains(string(combinedtable_female.t_foundin),'male'), : ); 
simdata_f=table2cell(simtable_f);
yakdata_f=table2cell(yaktable_f);
virdata_f=table2cell(virtable_f);
maledata_f=table2cell(maletable_f);
 %mean of virgin
 
vir_eventpeaks_mean_f=mean(cell2mat(virtable_f.eventpeaks_mean));
vir_eventpeaks_SEM_f=std(cell2mat(virtable_f.eventpeaks_mean))/sqrt(size(cell2mat(virtable_f.eventpeaks_mean),1));

cell_mean_event_f=cell2mat(transpose(virtable_f.mean_event(~cellfun(@isempty, virtable_f.mean_event))));

vir_mean_event_f=mean(cell_mean_event_f,2);
vir_SEM_event_f=std(cell_mean_event_f,0,2)/sqrt(size(cell_mean_event_f,2));

%mean of male

 
 
male_eventpeaks_mean_f=mean(cell2mat(maletable_f.eventpeaks_mean));
male_eventpeaks_SEM_f=std(cell2mat(maletable_f.eventpeaks_mean))/sqrt(size(cell2mat(maletable_f.eventpeaks_mean),1));

cell_mean_event_f=cell2mat(transpose(maletable_f.mean_event(~cellfun(@isempty, maletable_f.mean_event))));

male_mean_event_f=mean(cell_mean_event_f,2);
male_SEM_event_f=std(cell_mean_event_f,0,2)/sqrt(size(cell_mean_event_f,2));

%plot the mean event of virgin

%--for male experimental flies
mean_first_touch_event_m=cell2mat(transpose(virtable_m.first_touch_events(~cellfun(@isempty, virtable_m.first_touch_events))));
vir_mean_first_m=mean(mean_first_touch_event_m,2);
vir_SEM_first_m=std(mean_first_touch_event_m,0,2)/sqrt(size(mean_first_touch_event_m,2));

%plot the mean event of virgin
fignew2=figure('Name','virgin_first_touch_males');
%requires package boundedline
plot_first_touch_event_m=boundedline(x_events{2,1},vir_mean_first_m,vir_SEM_first_m,'m');
fignew=figure('Name','virgin_mean_event_males');
%requires package boundedline
plot_vir_event_m=boundedline(x_events{1,1},vir_mean_event_m,vir_SEM_event_m,'m');
cd(outputdirmean);
 saveas(fignew,'virgin_mean_event_male','epsc');
 saveas(fignew2,'virgin_first_touches_male','epsc');
%--for female experimental flies
mean_first_touch_event_f=cell2mat(transpose(virtable_f.first_touch_events(~cellfun(@isempty, virtable_f.first_touch_events))));
vir_mean_first_f=mean(mean_first_touch_event_f,2);
vir_SEM_first_f=std(mean_first_touch_event_f,0,2)/sqrt(size(mean_first_touch_event_f,2));

%plot the mean event of virgin
fignew2=figure('Name','virgin_first_touch_females');
%requires package boundedline
plot_first_touch_event_F=boundedline(x_events{2,1},vir_mean_first_f,vir_SEM_first_f,'m');
fignew=figure('Name','virgin_mean_event_females');
%requires package boundedline
plot_vir_event_f=boundedline(x_events{1,1},vir_mean_event_f,vir_SEM_event_f,'m');

cd(outputdirmean);
 saveas(fignew,'virgin_mean_event_female','epsc');
 saveas(fignew2,'virgin_first_touches_female','epsc');
 
 

%plot the mean event of male

%--for male experimental flies
mean_first_touch_event_m=cell2mat(transpose(maletable_m.first_touch_events(~cellfun(@isempty, maletable_m.first_touch_events))));
male_mean_first_m=mean(mean_first_touch_event_m,2);
male_SEM_first_m=std(mean_first_touch_event_m,0,2)/sqrt(size(mean_first_touch_event_m,2));

%plot the mean event of male
fignew2=figure('Name','male_first_touch_males');
%requires package boundedline
plot_first_touch_event_m=boundedline(x_events{2,1},male_mean_first_m,male_SEM_first_m,'m');
fignew=figure('Name','male_mean_event_males');
%requires package boundedline
plot_male_event_m=boundedline(x_events{1,1},male_mean_event_m,male_SEM_event_m,'m');
cd(outputdirmean);
 saveas(fignew,'male_mean_event_male','epsc');
 saveas(fignew2,'male_first_touches_male','epsc');
%--for female experimental flies
mean_first_touch_event_f=cell2mat(transpose(maletable_f.first_touch_events(~cellfun(@isempty, maletable_f.first_touch_events))));
male_mean_first_f=mean(mean_first_touch_event_f,2);
male_SEM_first_f=std(mean_first_touch_event_f,0,2)/sqrt(size(mean_first_touch_event_f,2));

%plot the mean event of male
fignew2=figure('Name','male_first_touch_females');
%requires package boundedline
plot_first_touch_event_F=boundedline(x_events{2,1},male_mean_first_f,male_SEM_first_f,'m');
fignew=figure('Name','male_mean_event_females');
%requires package boundedline
plot_male_event_f=boundedline(x_events{1,1},male_mean_event_f,male_SEM_event_f,'m');

cd(outputdirmean);
 saveas(fignew,'male_mean_event_female','epsc');
 saveas(fignew2,'male_first_touches_female','epsc');
 
% male_eventpeaks_mean=mean(cell2mat(maletable.eventpeaks_mean));
% male_eventpeaks_SEM=std(cell2mat(maletable.eventpeaks_mean))/sqrt(size(cell2mat(maletable.eventpeaks_mean),1));
% 
% cell_mean_event=cell2mat(transpose(maletable.mean_event(~cellfun(@isempty, maletable.mean_event))));
% male_mean_event=mean(cell_mean_event,2);
% male_SEM_event=std(cell_mean_event,0,2)/sqrt(size(cell_mean_event,2));
%plot the mean event of male
%fignew=figure('Name','male_mean_event');
%requires package boundedline
%plot_male_event=boundedline(x_events{1,1},male_mean_event,male_SEM_event,'m');
 %cd(outputdirmean);
 %saveas(fignew,'male_mean_event','epsc');
 
 
 
%  %mean of simulans
% sim_eventpeaks_mean=mean(cell2mat(simtable.eventpeaks_mean));
% sim_eventpeaks_SEM=std(cell2mat(simtable.eventpeaks_mean))/sqrt(size(cell2mat(simtable.eventpeaks_mean),1));
% 
% cell_mean_event=cell2mat(transpose(simtable.mean_event(~cellfun(@isempty, simtable.mean_event))));
% sim_mean_event=mean(cell_mean_event,2);
% sim_SEM_event=std(cell_mean_event,0,2)/sqrt(size(cell_mean_event,2));
% mean_first_touch_event=cell2mat(transpose(simtable.first_touch_events(~cellfun(@isempty, simtable.first_touch_events))));
% sim_mean_first=mean(mean_first_touch_event,2);
% sim_SEM_first=std(mean_first_touch_event,0,2)/sqrt(size(mean_first_touch_event,2));
% %plot the mean event of Simulans
% fignew2=figure('Name','simulans_first_touch');
% %requires package boundedline
% plot_first_touch_event=boundedline(x_events{2,1},sim_mean_first,sim_SEM_first,'m');
% fignew=figure('Name','simulans_mean_event');
% %requires package boundedline
% plot_sim_event=boundedline(x_events{2,1},sim_mean_event,sim_SEM_event,'m');
%  
%  cd(outputdirmean);
%  saveas(fignew,'simulans_mean_event','epsc');
%  saveas(fignew2,'simulans_first_touches','epsc');
% %mean of yakuba
% 
%  yak_eventpeaks_mean=mean(cell2mat(yaktable.eventpeaks_mean));
% yak_eventpeaks_SEM=std(cell2mat(yaktable.eventpeaks_mean))/sqrt(size(cell2mat(yaktable.eventpeaks_mean),1));
% 
% cell_mean_event=cell2mat(transpose(yaktable.mean_event(~cellfun(@isempty, yaktable.mean_event))));
% yak_mean_event=mean(cell_mean_event,2);
% yak_SEM_event=std(cell_mean_event,0,2)/sqrt(size(cell_mean_event,2));
% %plot the mean event of yakuba
% %fignew=figure('Name','yakuba_mean_event');
% %requires package boundedline
% %plot_yak_event=boundedline(x_events{1,1},yak_mean_event,yak_SEM_event,'m');
% %mean of virgin
% %cd(outputdirmean);
%  %saveas(fignew,'yakuba_mean_event','epsc');



%This part is the definition of the functions used in the previous parts of
%the script.

function [touchstartframes,eventsmat,eventpeaks,eventpeaks_mean,eventpeaks_SEM,mean_event,SEM_event,touchtimes,fluo,x_events,first_touch_event] = find_touch_events(data)
%function [eventpeaks_mean,eventpeaks_SEM,mean_event,SEM_event,touchtimes,fluo] = find_touch_events(data)

touchtimes=data{1};
fluo=data{2};
outputfig=string(data{3});
%framerate of imaging to be entered here
framerate=5.92;
%number of frames in the imaging file
numframes=600;
%time for calculating the baseline before each touch
basetime=3;
%time of the event after start of touch
eventtime=17;
%shift the matrix to the right by one 
%framerate of imaging to be entered here

touchtimes_shifted=circshift(touchtimes,[0,1]);
touchtimes_shifted(1)=0;
%subtract the shifted matrix from the original one (corresponds to
%substracting the previous element from each element
intervals=touchtimes-touchtimes_shifted;
%find intervals of more than 5s between the touches (output type is
%logical)
starts=intervals>=5;
%find starttimes of the touchevents
starttimes=starts.*touchtimes;%This contains zeros for all spaces in the matrix that are not starts of touch events

endtime_intervals=((numframes-1)/framerate)-touchtimes;

%find out if event starts at least 'eventtime' before end of recording (output type is
%logical)
ends_on_time=endtime_intervals>=eventtime+(1/framerate);
%find starttimes of the touchevents
starttimes=ends_on_time.*starttimes;%This contains zeros for all spaces in the matrix that do not end on time
%disp(starttimes);
touchstarts=nonzeros(starttimes);%reduce matrix to contain only starts
%calculate the frame number from the time of the touchstarts
touchstartframes=round(touchstarts*framerate);
%calculate the timepoints
x=1:numframes;
x=(x-1)/framerate;
%this is the definition of the plot_touches function
plot_touches=@(t) plot(x(t-round(basetime*framerate):t+round(eventtime*framerate)),fluo(t-round(basetime*framerate):t+round(eventtime*framerate)));
%this is the definition of the newfig function
newfig=@(tt) figure();
%this executes the functions newfig and plot_touches for each element of
%the array touchstartframes
%plotit=arrayfun(@(touchstart) cellfun(@(f) f(touchstart), {newfig,plot_touches},'UniformOutput', false), touchstartframes,'UniformOutput', false);
%this defines events and saves them to a cell array called events 
%the events are defined as the fluorescence trace starting at basetime
%before touchstart and ending at touchstart + eventtime
events=arrayfun(@(touchstart) fluo(touchstart-(ceil(basetime*framerate)):touchstart+floor(eventtime*framerate)), touchstartframes,'UniformOutput',false);
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
eventsmat=(eventsmat-eventbases1)/eventbases1;


else
  
end
mean_event=mean(eventsmat,2);
%SEM for each point in the averaged event
SEM_event=std(eventsmat,0,2)/sqrt(size(eventsmat,2));
%calculate single peak of each event during eventtime
first_touch_event=eventsmat(:,1);
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
%plot the mean event
figure('Name',outputfig);
%requires package boundedline
%plot_mean_event=boundedline(x_events,mean_event,'m');

plot(x_events,eventsmat,'k',x_events,mean_event,'m');
%function [eventsmat,event] = makemyevents(ev)
%event=transpose(ev);
%eventsmat=cell2mat(transpose(event));
%eventsmat=transpose(eventsmat);
%end


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
                      
                       for i=1:length(resultsarray)
                       if isempty(fffounds{i})==1
                          foundinfiles{i}=[];
                       else
                           
                            foundinfiles{i}=rresultfilenames{i};
                       end
                       end
                       fffounds=fffounds(~cellfun('isempty',fffounds));
                        foundinfiles=foundinfiles(~cellfun('isempty',foundinfiles));
                        iindex=iindex(~cellfun('isempty',iindex));
                      
                     
                       
                       end
                       function[singleresult]=resultfinder(nameoffile,indexoffile)
                       
                       expresults =table2array(readtable(nameoffile,'Sheet','Sheet1','ReadVariableNames',0));
                        singleresult=expresults(:,indexoffile);
 
                       end
                       
                       function[outputtimes]=expand_reduced_touchtimes(testtimes)
                       outputtimes=[];
                       
                       for i=1:2:length(testtimes)-1
                           %exclude touch periods > 5s
                           if (testtimes(i+1)-testtimes(i))<6
                               
                               for j=0:round(testtimes(i+1)-testtimes(i))
                                   outputtimes=[outputtimes;(testtimes(i)+j)];
                               end
                           end
                       end
                       end