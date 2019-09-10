%Annika Rings, September 2019
%dependencies: 
%requires MATLAB 2018 or later
%calculate_dff.m (custom function)
%extract_fluo.m (custom function)
function frequencyplot(foldername)

framerate = 5.92; % frame rate in Hz

 
baseline_start = 2;
baseline_end = 11;
startdir=pwd;
pathname = startdir;
frequencies=[4,10,20,40]; %LED frequencies of the experiments
pulsetimes = [20,40,60,80];%timings of the pulses
pulsedur =5;%duration (in s) of pulse bursts



subfoldername='ROI';%must be a folder within the imaging folder
stackdir = fullfile(pathname,foldername,subfoldername);
outputdir=strrep(pathname, 'imaging_preprocessed','Results');
cd (stackdir);
for i = 1:length(frequencies)
    f = string(frequencies(i));
    outputname = strcat(f,'Hz');
    %disp(f);
    files=dir(strcat('*',f,'Hz*.tif'));
    filenames=arrayfun(@(f) f.name,files, 'uni',false);
    %disp(filenames);
    fluo=cellfun(@(filename)extract_fluo(filename),filenames,'uni',false);
    fluomat=cell2mat(fluo);
   
    %calculateing deltaF/F
    dff=calculate_dff(fluomat,baseline_start,baseline_end);
    numframes = size(dff,2);
    framenumbers=1:numframes;
    x=framenumbers/framerate;
    
    %calculating mean, n and SEM of dff
    mean_dff=mean(dff);
    n_files=size(dff,1);
    SEM_dff=std(dff)./n_files;
    %make the figure name and path to output
    
    outputfig=fullfile(outputdir,(strcat(outputname,'.eps')));
    fignew=figure('Name',outputname);
    %plot the mean with a shaded area showing the SEM
    h=boundedline(x,mean_dff, SEM_dff,'k');
    xlim([0,105]);
    ylim([-0.2,0.8])
    for numpatch = 1:size(pulsetimes,2)%loop through the number of pulses
                %for each pulse, generate a shaded area in the plot
                %indicating the pulse duration
    hpatch(numpatch)=patch([pulsetimes(numpatch) pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)+pulsedur pulsetimes(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'r','EdgeColor','none');
    %send the shaded area to the back of the graph
    uistack(hpatch(numpatch), 'bottom');
    end
            saveas(fignew,outputfig,'epsc');
   dff_of_pulses=cellfun(@(f)dff_pulses(f,pulsetimes,pulsedur,framerate),fluo,'uni',false);
   pulsedff=cell2mat(dff_of_pulses);
 outputmatfile=fullfile(outputdir,(strcat(outputname,'.mat')));
 save(outputmatfile,'pulsedff','mean_dff','n_files','SEM_dff');
 pulsemeans(i)=mean(pulsedff);
 pulseSEMs(i)=std(pulsedff)/(numel(pulsedff));
end
outputplot=fullfile(outputdir,'frequencyplot.eps');
fignew=figure('Name','dF/F vs. frequency');
 
errorbar(frequencies,pulsemeans,pulseSEMs,'o','color','k','MarkerSize',10);
xlim([0,50]);
ylim([0,0.8]);
title('Frequency');
xlabel('frequency(Hz)');
ylabel ('\DeltaF/F');
ax = gca;
ax.FontSize = 13;
ax.LineWidth=2;
saveas(fignew,outputplot,'epsc');
    cd (startdir);
    

        
    

            

                
 

    
    

