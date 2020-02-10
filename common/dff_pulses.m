 function pulse_dff=dff_pulses(fluo, pulsetimes,pulsedur,framerate)
        for i=1:numel(pulsetimes)
            start_event=round(pulsetimes(i)*framerate);
            end_event = round(pulsetimes(i)*framerate+pulsedur*framerate);
            start_base=round(pulsetimes(i)*framerate-pulsedur*framerate)-3;
            end_base=round(pulsetimes(i)*framerate)-1;
            pulse_f0=mean(fluo(start_base:end_base));
            pulse_f=mean(fluo(start_event:end_event));
            dff=(pulse_f-pulse_f0)/pulse_f0;
        end
        pulse_dff=mean(dff);