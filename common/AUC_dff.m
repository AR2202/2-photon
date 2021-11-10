%function for calculating the AUC of the deltaF/F traces during the pulse
%until 'after' frames after the pulse.
% the input should already be deltaF/F
function auc = AUC_dff(dff, pulseframe, pulsedur, framerate, after)

x = (0:pulsedur + after);
x = x / framerate;

start_event = pulseframe;
end_event = pulseframe + pulsedur + after;


f = dff(start_event:end_event) ;


auc = trapz(x, f);
