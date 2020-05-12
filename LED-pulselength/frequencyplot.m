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
%'resultsname': name of folder where results should go, default'Results'

function frequencyplot(foldername,varargin)



options = struct('framerate',5.92,'baseline_start',2,'baseline_end',11,...
    'frequencies',[4,10,20,40], 'pulselengths',[8,12,20],...
    'pulsetimes',[20,40,60,80],'genders',{{'_male';'female'}},...
    'neuronparts',{{'medial';'lateral'}},'pulsedur', 5,...
    'resultsdir','Results','multiroi',false,'numrois',1,...
    'pulsetimesfromfile',false,'pulsetimesfile','stimtimes.mat');

%# read the acceptable names
optionNames = fieldnames(options);

%# count arguments - throw exception if the number is not divisible by 2
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
    error('frequencyplot called with wrong number of arguments: expected Name/Value pair arguments')
end

for pair = reshape(varargin,2,[]) %# pair is {propName;propValue}
    inpName = lower(pair{1}); %# make case insensitive
    %check if the entered key is a valid key
    %check if the entered key is a valid key. If yes, replace the default by
    %the caller specified value. Otherwise, throw and exception
    if any(strcmp(inpName,optionNames))
        
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end
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

if multiroi
    subfoldername='ROIS';%must be a folder within the imaging folder

    else
subfoldername='ROI';%must be a folder within the imaging folder
numrois =1; %set numrois to 1 if multiroi is false
end
stackdir = fullfile(pathname,foldername,subfoldername);

if exist(stackdir, 'dir')
    disp('exists');
    outputdir=strrep(pathname, 'imaging_preprocessed',resultsdir);
    directories.name = fullfile(pathname,foldername);
    pathname=directories.name;
    directories.isdir = 1;
    issubdir=true;
    
else
    disp('doesnt exist');
    outputdir=fullfile(pathname,resultsdir);
    directories = dir(foldername);
    issubdir=false;
    
end
for g=1:size(genders,1)
    
    gender=genders{g};
    disp(gender);
    for n=1:size(neuronparts,1)
        neuronpart=neuronparts{n};
    
    for j = 1:length(pulselengths)
        pulselengthname=strcat(string(pulselengths(j)),'ms_');
        disp(pulselengthname);
        for i = 1:length(frequencies)
            f = string(frequencies(i));
            outputname = strcat(pulselengthname,f,'Hz');
            filenames=[];
            
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
                disp(directoryname);
                end
                files=dir(char(strcat(directoryname,'/',subfoldername,'/*',gender,'*',neuronpart,'*',pulsedurstr,'*',f,'Hz*',pulselengthname,'*.tif')));
                newfilenames=arrayfun(@(f) fullfile(directoryname,subfoldername,f.name),files, 'uni',false);
                filenames = vertcat(filenames,newfilenames);
                disp(filenames);
            end
            fluo=cellfun(@(filename)extract_fluo(filename),filenames,'uni',false);
            fluomat=cell2mat(fluo);
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
   
            
            outputfig=fullfile(outputdir,(strcat(outputname,gender,'_',neuronpart,'_',pulsedurstr,'.eps')));
            fignew=figure('Name',strcat( outputname,gender,'_',neuronpart,'_',pulsedurstr));
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
            outputfig2=fullfile(outputdir,(strcat(outputname,gender,'_',neuronpart,'_',pulsedurstr,'mean_pulse.eps')));
            fignew2=figure('Name',strcat( outputname,gender,'_',neuronpart,'_',pulsedurstr,'_mean_pulse'));
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
            outputmatfile=fullfile(outputdir,(strcat(outputname,gender,'_',neuronpart,'_',pulsedurstr,'.mat')));
            save(outputmatfile,'pulsedff','mean_dff','n_files','SEM_dff','dff','mean_pulseav_dff', 'SEM_pulseav_dff','mean_first_dff','SEM_first_dff','mean_last_dff','SEM_last_dff');
            pulsemeans(j,i)=mean(pulsedff);
            pulseSEMs(j,i)=std(pulsedff)/(numel(pulsedff));
        end
    end
    
    outputplot=fullfile(outputdir,strcat(gender,'_',neuronpart,'frequencyplot.eps'));
    fignew=figure('Name',strcat('dF/F vs. frequency',gender,'_',neuronpart,'_',pulsedurstr));
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

function pulseav_dff=average_pulses(fluo, pulsetimes,framerate)
pulsefluo=zeros(size(pulsetimes,2),180);
for numpulse = 1:size(pulsetimes,2)
    pulseframe=floor(pulsetimes(numpulse)*framerate);
    pulsefluo(numpulse,1:180)=fluo((pulseframe-60):(pulseframe+119));
end
mean_pulsefluo=mean(pulsefluo,1);
pulseav_dff=calculate_dff(mean_pulsefluo,2,58);













