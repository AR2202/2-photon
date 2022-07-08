%This creates events of <eventdur> frames
%almost the same as average_pulses_shorter, could be merged
function pulseav_dff = average_pulses_odour(fluo, pulsetimes, framerate,align_pulse_to,eventdur)
baseline_end = align_pulse_to - 1;
after_pulse = eventdur - align_pulse_to;
pulsefluo = zeros(size(pulsetimes, 2), eventdur);
pulsefluo_dff = zeros(size(pulsetimes, 2), eventdur);
for numpulse = 1:size(pulsetimes, 2)
    pulseframe = floor(pulsetimes(numpulse)*framerate);
    if (pulseframe - baseline_end) < 1 || (pulseframe +after_pulse) > size(fluo, 2) %check if recording is long enough
        pulsefluo = pulsefluo (1:end-1,:);
        pulsefluo_dff = pulsefluo_dff (1:end-1,:);
        
    else
    pulsefluo(numpulse, 1:eventdur) = fluo((pulseframe - baseline_end):(pulseframe + after_pulse));
    pulsefluo_dff(numpulse, 1:eventdur) = calculate_dff(pulsefluo(numpulse, 1:eventdur), 2, baseline_end - 2);
end
end
pulseav_dff = mean(pulsefluo_dff, 1);
end

