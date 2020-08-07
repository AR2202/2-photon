%Annika Rings, September 2019
%
%FREQUENCYPLOT makes a plot of deltaF/F vs. Frequency for different
%pulsedurations
%
%dependencies:
%requires MATLAB 2018 or later
%requires the following functions:
%calculate_dff.m (custom function)
%extract_fluo.m (custom function)
%options_resolver.m (custom function)
%
%one required argument: folder to be analyzed
%takes the following optional key-value-pair arguments:
%'framerate': numeric (in Hz), default: 5.92
%'baseline_start': numeric (in frames), default: 2
%'baseline_end': numeric (in frames), default: 11
%'frequencies': 1-D array, default: [4,10,20,40]
%'pulselengths': 1-D array, default: [8,12,20]
%'pulsetimes': 1-D-array, default: [20,40,60,80]
%'genders': cell array, default: {'_female';'_male'}
%'neuronparts': cell array, default: {'medial';'lateral'}
%'pulsedur': numeric (in s), default 5
%'resultsdir': name of folder where results should go, default'Results'
%'multiroi': multiple ROIs per file, default false
%'numrois': number of ROIs per file ,default: 1
%'pulsetimesfromfile': read stimulation times from a file, default: false
%'pulsetimesfile': name of the file containing the stimulus times,
% only relevant if pulsetimesfromfile is set to true; default: 'stimtimes.mat'
% 'subfoldername': name of the imaging subfolder
% (a subdirectory of 'foldername' or of each of its subdirectories), default: 'ROI'



function frequencyplot(foldername,varargin)



options = struct('framerate',5.92,'baseline_start',2,'baseline_end',11,...
    'frequencies',[4,10,20,40], 'pulselengths',[8,12,20],...
    'pulsetimes',[20,40,60,80],'genders',{{'_male';'female'}},...
    'neuronparts',{{'medial';'lateral'}},'pulsedur', 5,...
    'inhibitor_conc',[0,150,300],...
    'inhibitor_unit','uM',...
    'inhibitor_name','PTX',...
    'resultsdir','Results','multiroi',false,'numrois',1,...
    'pulsetimesfromfile',false,'pulsetimesfile','stimtimes.mat','subfoldername','ROI');
arguments = varargin;

%call the options_resolver function to check optional key-value pair
%arguments
[options,~]=options_resolver(options,arguments,'frequencyplot');

%this block gets all the values from the optional function arguments
%for all arguments that were not specified, the default is used


framerate = options.framerate; % frame rate in Hz


baseline_start = options.baseline_start;
baseline_end = options.baseline_end;

frequencies=options.frequencies; %LED frequencies of the experiments
pulselengths=options.pulselengths;
genders = options.genders;
neuronparts=options.neuronparts;
pulsedur =options.pulsedur;%duration (in s) of pulse bursts
resultsdir=options.resultsdir;
multiroi=options.multiroi;
numrois=options.numrois;
pulsetimesfromfile=options.pulsetimesfromfile;
pulsetimesfile=options.pulsetimesfile;
inhibconc=options.inhibitor_conc;
inhibname=options.inhibitor_name;
inhibunit=options.inhibitor_unit;
if pulsetimesfromfile
    load(pulsetimesfile);
    pulsetimes = stimstarts./framerate;
else
    pulsetimes = options.pulsetimes;%timings of the pulses
end

if pulsedur == 0.2
    pulsedurstr = '200ms';
elseif pulsedur == 1
    pulsedurstr = '1s';
elseif pulsedur == 5
    pulsedurstr = '5s';
else pulsedurstr = '';
end
disp(pulsedurstr);

startdir=pwd;
pathname = startdir;
subfoldername=options.subfoldername;%must be a folder within the imaging folder

if ~multiroi
    
    numrois =1; %set numrois to 1 if multiroi is false
end
stackdir = fullfile(pathname,foldername,subfoldername);

if exist(stackdir, 'dir')
    
    outputdir=strrep(pathname, 'imaging_preprocessed',resultsdir);
    directories.name = fullfile(pathname,foldername);
    pathname=directories.name;
    directories.isdir = 1;
    issubdir=true;
    
else
    
    outputdir=fullfile(pathname,resultsdir);
    directories = dir(foldername);
    issubdir=false;
    
end
for g=1:size(genders,1)
    
    gender=genders{g};
    disp(gender);
    for n=1:size(neuronparts,1)
        neuronpart=neuronparts{n};
        for inhib = 1:length(inhibconc)
            inhibstring = strcat(string(inhibconc(inhib)),inhibunit,inhibname);
            disp(inhibstring);
            
            for j = 1:length(pulselengths)
                pulselengthname=strcat(string(pulselengths(j)),'ms_');
                disp(pulselengthname);
                for i = 1:length(frequencies)
                    f = string(frequencies(i));
                    outputname = strcat(pulselengthname,f,'Hz');
                    all_filenames=[];
                    all_directorynames={};
                    
                    
                    for p = 1:numel(directories)
                        if ~directories(p).isdir
                            continue;
                        end
                        if ismember(directories(p).name,{'.','..','.DS_Store'})
                            continue;
                        end
                        if issubdir
                            directoryname=pathname;
                        else
                            directoryname = fullfile(pathname,foldername,directories(p).name);
                            %disp(directoryname);
                            
                        
                            
                        end
                        files=dir(char(strcat(directoryname,'/',subfoldername,'/*',gender,'*',neuronpart,'*',pulsedurstr,'*',f,'Hz*',pulselengthname,'*.tif')));
                        newfilenames=arrayfun(@(f) fullfile(directoryname,subfoldername,f.name),files, 'uni',false);
                        newdirectorynames=arrayfun(@(f) fullfile(directoryname),files, 'uni',false);
                        all_filenames = vertcat(all_filenames,newfilenames);
                        all_directorynames = vertcat(all_directorynames,newdirectorynames);
                        if inhibconc(inhib) ==0
                            filenames = all_filenames(~contains(all_filenames,inhibname));
                            directorynames = all_directorynames(~contains(all_filenames,inhibname));
                        else
                            filenames = all_filenames(contains(all_filenames,inhibstring));
                            directorynames = all_directorynames(contains(all_filenames,inhibstring));
                        end
                        
                       % disp(filenames);
                       % disp(directorynames);
                    end
                    disp(filenames);
                    flynumbers=cellfun(@(filename)regexp(filename,"fly\d+(",'match'),filenames,'uni',false);
                   % disp(flynumbers);
                    fluo_all=cellfun(@(filename)extract_fluo(filename),filenames,'uni',false);
                    fluomat_all=cell2mat(fluo_all);
                    fluo_av=cellfun(@(directoryname1,flynumber1) average_within_fly(directorynames,flynumbers,fluomat_all,directoryname1,flynumber1),directorynames,flynumbers,'uni',false);
                    fluomat_av=cell2mat(fluo_av);
                    fluomat=unique(fluomat_av,'row');
                    fluo=num2cell(fluomat,2);
                    pulseaverage_dff=cellfun(@(f) average_pulses(f,pulsetimes,framerate),fluo,'uni',false);
                    pulseavmat=cell2mat(pulseaverage_dff);
                    
                    firstpulse_dff=cellfun(@(f) average_pulses(f,pulsetimes(1),framerate),fluo,'uni',false);
                    firstmat=cell2mat(firstpulse_dff);
                    
                    lastpulse_dff=cellfun(@(f) average_pulses(f,pulsetimes(size(pulsetimes,2)),framerate),fluo,'uni',false);
                    lastmat=cell2mat(lastpulse_dff);
                    
                    
                    %calculating deltaF/F
                    dff=calculate_dff(fluomat,baseline_start,baseline_end);
                    numframes = size(dff,2);
                    
                    framenumbers=1:numframes;
                    x=framenumbers/framerate;
                    
                    %calculating mean, n and SEM of dff
                    mean_dff=mean(dff);
                    n_files=size(dff,1)/numrois;
                    n_rois=size(dff,1);
                    SEM_dff=std(dff)./n_files;
                    mean_pulseav_dff=mean(pulseavmat,1);
                    SEM_pulseav_dff=std(pulseavmat)./n_files;
                    mean_first_dff=mean(firstmat,1);
                    SEM_first_dff=std(firstmat)./n_files;
                    mean_last_dff=mean(lastmat,1);
                    SEM_last_dff=std(lastmat)./n_files;
                    %make the figure name and path to output
                    
                    
                    outputfig=fullfile(outputdir,(strcat(outputname,gender,'_',neuronpart,'_',pulsedurstr,inhibstring,'.eps')));
                    fignew=figure('Name',strcat( outputname,gender,'_',neuronpart,'_',pulsedurstr,inhibstring));
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
                    outputfig2=fullfile(outputdir,(strcat(outputname,gender,'_',neuronpart,'_',pulsedurstr,inhibstring,'mean_pulse.eps')));
                    fignew2=figure('Name',strcat( outputname,gender,'_',neuronpart,'_',pulsedurstr,inhibstring,'_mean_pulse'));
                    %plot the mean with a shaded area showing the SEM
                    x2=1:180;
                    h=boundedline(x2,(transpose(mean_pulseav_dff)), transpose(SEM_pulseav_dff),'k');
                    xlim([0,180]);
                    ylim([-0.2,0.8])
                    
                    hpatch2=patch([61 91 91 61] , [min(ylim)*[1 1] max(ylim)*[1 1]],'r','EdgeColor','none');
                    %send the shaded area to the back of the graph
                    uistack(hpatch2, 'bottom');
                    
                    saveas(fignew2,outputfig2,'epsc');
                    dff_of_pulses=cellfun(@(f)dff_pulses(f,pulsetimes,pulsedur,framerate),fluo,'uni',false);
                    
                    pulsedff=cell2mat(dff_of_pulses);
                    outputmatfile=fullfile(outputdir,(strcat(outputname,gender,'_',neuronpart,'_',pulsedurstr,inhibstring,'.mat')));
                    save(outputmatfile,'pulsedff','mean_dff','n_files','SEM_dff','dff','mean_pulseav_dff', 'SEM_pulseav_dff','mean_first_dff','SEM_first_dff','mean_last_dff','SEM_last_dff');
                    pulsemeans(j,i)=mean(pulsedff);
                    pulseSEMs(j,i)=std(pulsedff)/(numel(pulsedff));
                end
            end
            
            outputplot=fullfile(outputdir,strcat(gender,'_',neuronpart,inhibstring,'frequencyplot.eps'));
            fignew=figure('Name',strcat('dF/F vs. frequency',gender,'_',neuronpart,'_',pulsedurstr,inhibstring));
            colors=['k','r','b','g'];
            hold 'on';
            for j=1:size(pulsemeans,1)
                errorbar(frequencies,pulsemeans(j,:),pulseSEMs(j,:),'o','color',colors(j),'MarkerSize',10);
            end
            
            xlim([0,100]);
            ylim([0,2.5]);
            title('Frequency');
            xlabel('frequency(Hz)');
            ylabel ('\DeltaF/F');
            ax = gca;
            ax.FontSize = 13;
            ax.LineWidth=2;
            hold 'off';
            saveas(fignew,outputplot,'epsc');
            cd (startdir);
        end
    end
end
end
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
%function for checking if data are from the same animal
function average_event=average_within_fly(directorynames,flynumbers,fluo,directoryname1,flynumber1)

sames = cellfun(@(directoryname,flynumber)...
    (contains(directoryname,directoryname1) && contains(flynumber,flynumber1)),...
    directorynames,flynumbers);
%checking if both the flynumber and the directoryname in which the 
%experiment was found is the same
total_fluo=fluo(sames,:);

average_event=mean(total_fluo,1);
end
