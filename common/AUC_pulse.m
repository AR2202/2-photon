%function for calculating the AUC of the deltaF/F traces during the pulse
%until 'after' frames after the pulse. Baseline: 'baseline' frames before the pulse
function auc = AUC_pulse(fluo, pulseframe, pulsedur, framerate, baseline, after)

x = (0:pulsedur + after - 1);
x = x / framerate;

start_event = pulseframe;
end_event = pulseframe + pulsedur + after;
start_base = pulseframe - baseline;
end_base = pulseframe - 1;
pulse_f0 = mean(fluo(start_base:end_base));

df = fluo(start_event:end_event) - pulse_f0;

dff = df ./ pulse_f0;
auc = trapz(x, dff);
