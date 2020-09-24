function event = detectSpontaneous(filename) 
load(filename, 'dff');
 gliding_av_dff_all=movmean(dff(:,:),10);
 shifted = circshift(gliding_av_dff_all,10);
 shifted(:,1:10)=0;
 difference = gliding_av_dff_all - shifted;
 diffcell=num2cell(difference,2);
 event = cellfun (@(diff) find(diff>0.05), diffcell, 'UniformOutput', false);
 