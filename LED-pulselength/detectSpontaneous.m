function [freqs,ampls] = detectSpontaneous(filename,varargin) 
%------------------------------------------------------------------------
%optional key-value pare arguments and their defaults
%------------------------------------------------------------------------
options = struct('threshold',0.1);
arguments = varargin;
%------------------------------------------------------------------------
%setting optional key-value pair arguments
%-------------------------------------------------------------------------

%call the options_resolver function to check optional key-value pair
%arguments
[options,~]=options_resolver(options,arguments,'detectSpontaneous');
threshold = options.threshold; 
load(filename, 'dff');
 dffcell = num2cell(dff,2);
 gliding_av_dff_all=movmean(dff(:,:),2);
 shifted = circshift(gliding_av_dff_all,2);
 shifted(:,1:2)=0;
 difference = gliding_av_dff_all - shifted;
 aboveth = difference >threshold;
 edges = diff(aboveth,1,2);
 edgecell=num2cell(edges,2);
 eventstarts = cellfun (@(edge) find(edge==1), edgecell, 'UniformOutput', false);
 freqs = cellfun (@(exp) size(exp,2)/101, eventstarts, 'UniformOutput', false);
ampls = cellfun(@(dff1,eventstarts1) plotEvents(dff1,eventstarts1), dffcell, eventstarts, 'UniformOutput', false);
 
 
 function ampl= plotEvents(dff,starts)
maxevents = [];
figure('Name', 'events');
hold 'on';
for start = 1:size(starts,2)
    startpoint = min(max(starts(start)-3,1),size(dff,2)-17);
    endpoint = startpoint +17;
    event = dff(startpoint:endpoint);
    plot(event);
    
    maxevent = max(event) - event(1);
    
    maxevents(start) = maxevent;
    
end
hold 'off';

ampl = mean(maxevents,2);
 
 