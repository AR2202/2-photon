%Annika Rings Juli 2017
%This is a test script for testing finding touch events in imaging data
%The test script is for a single experiment
%This is later to be incorporated into a loop over all experiments

%framerate of imaging to be entered here
framerate=2;
%number of frames in the imaging file
numframes=200;
%time for calculating the baseline before each touch
basetime=2.5;
%time of the event after start of touch
eventtime=5;

%create touchtimes matrix
touchtimes=[10,11,15,26,28,30,41,42,44,55,56];
%creates fluorescence data matrix
fluo=rand(numframes);
%shift the matrix to the right by one 
touchtimes_shifted=circshift(touchtimes,[0,1]);
touchtimes_shifted(1)=0;
%subtract the shifted matrix from the original one (corresponds to
%substracting the previous element from each element
intervals=touchtimes-touchtimes_shifted;
%find intervals of more than 10s between the touches (output type is
%logical)
starts=intervals>=10;
%find starttimes of the touchevents
starttimes=starts.*touchtimes;%This contains zeros for all spaces in the matrix that are not starts of touch events
touchstarts=nonzeros(starttimes);%reduce matrix to contain only starts
%calculate the frame number from the time of the touchstarts
touchstartframes=round(touchstarts*framerate);
%calculate the timepoints
x=[1:numframes];
x=(x-1)/framerate;
%this is the definition of the plot_touches function
plot_touches=@(t) plot(x(t-round(basetime*framerate):t+round(eventtime*framerate)),fluo(t-round(basetime*framerate):t+round(eventtime*framerate)));
%this is the definition of the newfig function
newfig=@(tt) figure();
%this executes the functions newfig and plot_touches for each element of
%the array touchstartframes
plotit=arrayfun(@(touchstart) cellfun(@(f) f(touchstart), {newfig,plot_touches},'UniformOutput', false), touchstartframes,'UniformOutput', false);
%this defines events and saves them to a cell array called events 
%the events are defined as the fluorescence trace starting at basetime
%before touchstart and ending at touchstart + eventtime
events=arrayfun(@(touchstart) fluo(touchstart-round(basetime*framerate):touchstart+round(eventtime*framerate)), touchstartframes,'UniformOutput',false);
%convert cell array events to a matrix - necessary for subsequent
%calculations
eventsmat=cell2mat(transpose(events));
%average all events frame by frame (after aligning them to the start of the
%touch event)
mean_event=mean(eventsmat,2);
%SEM for each point in the averaged event
SEM_event=std(eventsmat,0,2)/sqrt(size(eventsmat,2));
%calculate single peak of each event during eventtime
eventpeaks=transpose(max(eventsmat((round(basetime*framerate)+1:round((basetime+eventtime)*framerate+1)),:)));
% baseline for each event before the touch
eventbases=transpose(mean(eventsmat(1:round(basetime*framerate),:)));
%calculate deltaF/F for that event
eventpeaks_dff=(eventpeaks-eventbases)./eventbases;
%calculate the mean of the peaks of single events
eventpeaks_mean=mean(eventpeaks);
eventpeaks_SEM=std(eventpeaks,0,1)/sqrt(size(eventpeaks,1));
%make the x (timepoints) for the events - times are relative to the onset
%of the touch
x_events=x(1:round((basetime+eventtime)*framerate)+1)-basetime;
%plot the mean event
plot_mean_event=boundedline(x_events,mean_event,SEM_event,'m');



