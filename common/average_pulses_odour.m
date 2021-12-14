%This creates events of 180 frames
%almost the same as average_pulses_shorter, could be merged
function pulseav_dff = average_pulses_odour(fluo, pulsetimes, framerate)
pulsefluo = zeros(size(pulsetimes, 2), 180);
pulsefluo_dff = zeros(size(pulsetimes, 2), 180);
for numpulse = 1:size(pulsetimes, 2)
    pulseframe = floor(pulsetimes(numpulse)*framerate);
    if (pulseframe - 80) < 1 || (pulseframe + 99) > size(fluo, 2) %check if recording is long enough
        pulsefluo = pulsefluo (1:end-1,:);
        pulsefluo_dff = pulsefluo_dff (1:end-1,:);
        
    else
    pulsefluo(numpulse, 1:180) = fluo((pulseframe-80):(pulseframe + 99));
    pulsefluo_dff(numpulse, 1:180) = calculate_dff(pulsefluo(numpulse, 1:180), 2, 78);
end
end
pulseav_dff = mean(pulsefluo_dff, 1);
end

