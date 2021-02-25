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

function odourstim(foldername,varargin)

arguments = varargin;

options = struct('framerate',5.92,'baseline_start',2,'baseline_end',11,...
    'odours',{{'cVA';'phenylacetic'}},'pulsetimes',[15],'genders',{{'_male';'female'}},...
    'neuronparts',{{'medial';'lateral'}},'pulsedur', 5,...
    'resultsdir','Results','multiroi',false,'numrois',1,...
    'inhibitor_conc',[0],...
    'inhibitor_unit','uM',...
    'inhibitor_name','PTX',...
    'pulsetimesfromfile',false,'pulsetimesfile','stimtimes.mat');

%------------------------------------------------------------------------
%setting optional key-value pair arguments
%-------------------------------------------------------------------------

%call the options_resolver function to check optional key-value pair
%arguments
[options,~]=options_resolver(options,arguments,'odourstim');

%this block gets all the values from the optional function arguments
%for all arguments that were not specified, the default is used
%this block gets all the values from the optional function arguments
%for all arguments that were not specified, the default is used


framerate = options.framerate; % frame rate in Hz


baseline_start = options.baseline_start;
baseline_end = options.baseline_end;


genders = options.genders;
neuronparts=options.neuronparts;
pulsedur =options.pulsedur;%duration (in s) of pulse bursts
resultsdir=options.resultsdir;
multiroi=options.multiroi;
numrois=options.numrois;
pulsetimesfromfile=options.pulsetimesfromfile;
pulsetimesfile=options.pulsetimesfile;
odours=options.odours;
inhibconc=options.inhibitor_conc;
inhibname=options.inhibitor_name;
inhibunit=options.inhibitor_unit

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

%---------------------------------------------------------------------
%determine if single folder or multiple folders should be analyzed
%---------------------------------------------------------------------

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

%-------------------------------------------------------
%the main loop
%-------------------------------------------------------

%loop through the genders
for g=1:size(genders,1)
    
    gender=genders{g};
    disp(gender);
    %loop through the neuronparts
    for n=1:size(neuronparts,1)
        neuronpart=neuronparts{n};
        for inhib = 1:length(inhibconc)
            inhibstring = strcat(string(inhibconc(inhib)),inhibunit,inhibname);
            disp(inhibstring);
            %loop through the odours
            for o=1:size(odours,1)
                odour=odours{o};
                
                
                all_filenames=[];
                all_directorynames={};
                
                %loop through directories
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
                        
                        
                        
                        
                    end
                    %the expected structure of the filenames
                    files=dir(char(strcat(directoryname,'/',subfoldername,'/*',gender,'*',neuronpart,'*',odour,'*.tif')));
                    newfilenames=arrayfun(@(f) fullfile(directoryname,subfoldername,f.name),files, 'uni',false);
                    newdirectorynames=arrayfun(@(f) fullfile(directoryname),files, 'uni',false);
                    all_filenames = vertcat(all_filenames,newfilenames);
                    all_directorynames = vertcat(all_directorynames,newdirectorynames);
                    %if inhibitor_conc is 0, make sure the filename
                    %does not contain the inhibitorname. otherwise,
                    %find the concentration given in the filename
                    if inhibconc(inhib) ==0
                        filenames = all_filenames(~contains(all_filenames,inhibname));
                        directorynames = all_directorynames(~contains(all_filenames,inhibname));
                    else
                        filenames = all_filenames(contains(all_filenames,inhibstring));
                        directorynames = all_directorynames(contains(all_filenames,inhibstring));
                    end
                    
                    
                end
                disp(filenames);
                
                flynumbers=cellfun(@(filename)regexp(filename,'fly\d+(\(|\_)','match'),filenames,'uni',false);
                %extract fluorescence for all files using the (external) extract_fluo
                %function
                fluo_all=cellfun(@(filename)extract_fluo(filename),filenames,'uni',false);
                %convert to matrix
                fluomat_all=cell2mat(fluo_all);
                %average all experiments that come from the same fly
                %(i.e. have the same fly number and the same directory
                %name)
                [fluo_av,flyidentifiers]=cellfun(@(directoryname1,flynumber1) average_within_fly(directorynames,flynumbers,fluomat_all,directoryname1,flynumber1),directorynames,flynumbers,'uni',false);
                fluomat_av=cell2mat(fluo_av);
                fluomat=unique(fluomat_av,'row','stable');
                fluo=num2cell(fluomat,2);
                uniqueflies=unique(flyidentifiers,'stable');
                %average the traces
                pulseaverage_dff=cellfun(@(f) average_pulses_odour(f,pulsetimes,framerate),fluo,'uni',false);
                pulseavmat=cell2mat(pulseaverage_dff);
                %first pulses
                firstpulse_dff=cellfun(@(f) average_pulses_odour(f,pulsetimes(1),framerate),fluo,'uni',false);
                firstmat=cell2mat(firstpulse_dff);
                %last pullses
                lastpulse_dff=cellfun(@(f) average_pulses_odour(f,pulsetimes(size(pulsetimes,2)),framerate),fluo,'uni',false);
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
                
                outputfig=fullfile(outputdir,(strcat(gender,'_',neuronpart,'_',odour,'.eps')));
                fignew=figure('Name',strcat( gender,'_',neuronpart,'_',odour));
                %plot the mean with a shaded area showing the SEM
                h=boundedline(x,mean_dff, SEM_dff,'k');
                xlim([0,35]);
                ylim([-0.2,1.8])
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
                
                outputmatfile=fullfile(outputdir,(strcat(gender,'_',neuronpart,'_',odour,'.mat')));
                save(outputmatfile,'pulsedff','mean_dff','n_files','SEM_dff','dff');
                
            end
        end
        
        
        cd (startdir);
    end
end


