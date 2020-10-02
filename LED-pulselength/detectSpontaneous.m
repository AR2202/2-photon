function [freqs,ampls,aucs] = detectSpontaneous(filename,varargin) 
%------------------------------------------------------------------------
%optional key-value pare arguments and their defaults
%------------------------------------------------------------------------
options = struct('threshold',0.1,'framerate',5.92);
arguments = varargin;
%------------------------------------------------------------------------
%setting optional key-value pair arguments
%-------------------------------------------------------------------------

%call the options_resolver function to check optional key-value pair
%arguments
[options,~]=options_resolver(options,arguments,'detectSpontaneous');
threshold = options.threshold; 
framerate=options.framerate;
%load file
load(filename, 'dff');
 dffcell = num2cell(dff,2);
 gliding_av_dff_all=movmean(dff(:,:),3);
 shifted = circshift(gliding_av_dff_all,6);
 shifted(:,1:6)=0;
 difference = gliding_av_dff_all - shifted;
 aboveth = difference >threshold;
 edges = diff(aboveth,1,2);
 edgecell=num2cell(edges,2);
 eventstarts = cellfun (@(edge) find(edge==1), edgecell, 'UniformOutput', false);
 freqs = cellfun (@(exp) size(exp,2)/101, eventstarts, 'UniformOutput', false);
[ampls,aucs] = cellfun(@(dff1,eventstarts1) plotEvents(dff1,eventstarts1,framerate), dffcell, eventstarts, 'UniformOutput', false);
 
 
 function [ampl,auc]= plotEvents(dff,starts,framerate)
maxevents = [];
aucs=[];

figure('Name', 'events');
hold 'on';
for start = 1:size(starts,2)
    startpoint = min(max(starts(start)-6,1),size(dff,2)-29);
    endpoint = startpoint +29;
    event = dff(startpoint:endpoint)-mean(dff(startpoint:startpoint+5));
    x=[1:size(event,2)];
    x=x/framerate;
    plot(x,event);
    
    [maxevent,idx] = max(event);
    idx_start_auc=min(max(1,idx-3),size(event,2)-6);
    
    maxevents(start) = maxevent;
    auc=trapz(x(idx_start_auc:idx_start_auc+6),event(idx_start_auc:idx_start_auc+6));
    aucs(start)=auc;
    
end
hold 'off';

ampl = mean(maxevents,2);
auc = mean(aucs,2);
 
 