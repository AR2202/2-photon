%function for checking if data are from the same animal
function [average_event,fly_identifier]=average_within_fly(directorynames,flynumbers,fluo,directoryname1,flynumber1)
%disp(directoryname1)
%disp(flynumber1)
fly_identifier = char(strcat(directoryname1,flynumber1));
%disp(fly_identifier);
sames = cellfun(@(directoryname,flynumber)...
    (contains(directoryname,directoryname1) && contains(flynumber,flynumber1)),...
    directorynames,flynumbers);
%checking if both the flynumber and the directoryname in which the 
%experiment was found is the same
total_fluo=fluo(sames,:);

average_event=mean(total_fluo,1);
end
