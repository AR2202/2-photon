%This creates events of 180 frames
function pulseav_dff=average_pulses(fluo, pulsetimes,framerate)
pulsefluo=zeros(size(pulsetimes,2),180);
pulsefluo_dff=zeros(size(pulsetimes,2),180);
for numpulse = 1:size(pulsetimes,2)
    pulseframe=floor(pulsetimes(numpulse)*framerate);
    pulsefluo(numpulse,1:180)=fluo((pulseframe-60):(pulseframe+119));
    pulsefluo_dff(numpulse,1:180)=calculate_dff(pulsefluo(numpulse,1:180),2,58);
end

pulseav_dff=mean(pulsefluo_dff,1);
end
