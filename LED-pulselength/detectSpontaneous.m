function event = detectSpontaneous(filename) 
load(filename, 'dff');
 dffcell = num2cell(dff,2);
 gliding_av_dff_all=movmean(dff(:,:),10);
 shifted = circshift(gliding_av_dff_all,10);
 shifted(:,1:10)=0;
 difference = gliding_av_dff_all - shifted;
 diffcell=num2cell(difference,2);
 event = cellfun (@(diff) find(diff>0.05), diffcell, 'UniformOutput', false);
 aboveth = difference >0.1;
 edges = diff(aboveth,1,2);
 edgecell=num2cell(edges,2);
 eventstarts = cellfun (@(edge) find(edge==1), edgecell, 'UniformOutput', false);
 freqs = cellfun (@(exp) size(exp,2)/101, eventstarts, 'UniformOutput', false);
 plotevents = cellfun(@(dff1,eventstarts1) plotEvents(dff1,eventstarts1), dffcell, eventstarts, 'UniformOutput', false);
 
 
 function events= plotEvents(dff,starts)
events=zeros(size(starts,2),18);
figure('Name', 'events');
hold 'on';
for start = 1:size(starts,2)
    startpoint = min(max(starts(start)-6,1),size(dff,2)-17);
    endpoint = startpoint +17;
    event = dff(startpoint:endpoint);
    plot(event);
    events(start,:)=event;
    
end
hold 'off';
 
 