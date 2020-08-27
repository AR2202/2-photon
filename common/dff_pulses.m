 function pulse_dff=dff_pulses(fluo, pulsetimes,pulsedur,framerate)
 pulsedff=zeros(numel(pulsetimes),round(pulsedur*framerate+framerate));
 %aucs = zeros(numel(pulsetimes),1);
 x=(0:round(pulsedur*framerate+framerate)-1);
 x=x/framerate;
        for i=1:numel(pulsetimes)
            start_event=round(pulsetimes(i)*framerate);
            end_event = round(pulsetimes(i)*framerate)+round(pulsedur*framerate+framerate)-1;
            start_base=round(pulsetimes(i)*framerate-framerate)-1;
            end_base=round(pulsetimes(i)*framerate)-1;
            pulse_f0=mean(fluo(start_base:end_base));
            
            df = fluo(start_event:end_event)-pulse_f0;
            
            dff=df./pulse_f0;
            %auc=trapz(x,dff);
            pulsedff(i,:)=dff;
           % aucs(i)=auc;
            
            
        end
        mean_dff=mean(pulsedff);
        
        %pulse_dff=mean(mean_dff);
        
        
        auc=trapz(x,mean_dff);
       % disp(aucs);
        %pulse_dff=mean(aucs,1);
       % disp(pulse_dff);
       
       pulse_dff=auc;
      
        