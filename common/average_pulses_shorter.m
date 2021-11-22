%This creates events of 180 frames
function pulseav_dff = average_pulses_shorter(fluo, pulsetimes, framerate)
pulsefluo = zeros(size(pulsetimes, 2), 150);
pulsefluo_dff = zeros(size(pulsetimes, 2), 150);
for numpulse = 1:size(pulsetimes, 2)
    pulseframe = floor(pulsetimes(numpulse)*framerate);
    if (pulseframe - 60) < 1 || (pulseframe + 89) > size(fluo, 2) %check if recording is long enough
        pulsefluo = pulsefluo (1:end-1,:);
        pulsefluo_dff = pulsefluo_dff (1:end-1,:);
        
    else
        pulsefluo(numpulse, 1:150) = fluo((pulseframe - 60):(pulseframe + 89));
        pulsefluo_dff(numpulse, 1:150) = calculate_dff(pulsefluo(numpulse, 1:150), 2, 58);
    end
end

pulseav_dff = mean(pulsefluo_dff, 1);
end
