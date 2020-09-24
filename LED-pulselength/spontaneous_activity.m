%Annika Rings, September 2019
%
%SPONTANEOUS_ACTIVITY 
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

%'genders': cell array, default: {'_female';'_male'}
%'neuronparts': cell array, default: {'medial';'lateral'}

%'resultsdir': name of folder where results should go, default'Results'
%'multiroi': multiple ROIs per file, default false
%'numrois': number of ROIs per file ,default: 1

% 'subfoldername': name of the imaging subfolder
% (a subdirectory of 'foldername' or of each of its subdirectories), default: 'ROI'

%'inhibitor_conc': list of concentrations of toxin used, default:
%[0,150,300]
% if no inhibitor was used, choose [0]
% 'inhibitor_unit': unit of the inhibitor concentration, as given in the
% filename; irrelevant if no inhibitor was used, default: 'uM'
% 'inhibitor_name': string of the name of the inhibitor as given in the
% filename, defalut: 'PTX'

function spontaneous_activity(foldername,varargin)



options = struct('framerate',5.92,'baseline_start',2,'baseline_end',11,...
    'genders',{{'_male';'female'}},...
    'neuronparts',{{'medial';'lateral'}},...
    'inhibitor_conc',[0,150,300],...
    'inhibitor_unit','uM',...
    'inhibitor_name','PTX',...
    'resultsdir','Results','multiroi',false,'numrois',1,...
    'subfoldername','ROI');
arguments = varargin;

%------------------------------------------------------------------
%             Checking optional arguments
%-----------------------------------------------------------------

%call the options_resolver function to check optional key-value pair
%arguments
[options,~]=options_resolver(options,arguments,'spontaneous_activity');

%this block gets all the values from the optional function arguments
%for all arguments that were not specified, the default is used


framerate = options.framerate; % frame rate in Hz
baseline_start = options.baseline_start;
baseline_end = options.baseline_end;
genders = options.genders;
neuronparts=options.neuronparts;
resultsdir=options.resultsdir;
multiroi=options.multiroi;
numrois=options.numrois;
inhibconc=options.inhibitor_conc;
inhibname=options.inhibitor_name;
inhibunit=options.inhibitor_unit;

startdir=pwd;
pathname = startdir;
subfoldername=options.subfoldername;%must be a folder within the imaging folder

if ~multiroi
    
    numrois =1; %set numrois to 1 if multiroi is false
end
%------------------------------------------------------------
%test if there are several folders or only one to be analyzed
%------------------------------------------------------------

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
%-----------------------------------------------------
%the main loop
%-----------------------------------------------------

for g=1:size(genders,1)
    
    gender=genders{g};
    disp(gender);
    for n=1:size(neuronparts,1)
        neuronpart=neuronparts{n};
        for inhib = 1:length(inhibconc)
            inhibstring = strcat(string(inhibconc(inhib)),inhibunit,inhibname);
            disp(inhibstring);
            
            
            all_filenames={};
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
                    
                    
                    
                    
                end
                files=dir(char(strcat(directoryname,'/',subfoldername,'/*',gender,'*',neuronpart,'*.tif')));
                
                newfilenames=arrayfun(@(f) fullfile(directoryname,subfoldername,f.name),files, 'uni',false);
                
                newdirectorynames=arrayfun(@(f) fullfile(directoryname),files, 'uni',false);
                all_filenames = vertcat(all_filenames,newfilenames);
                all_directorynames = vertcat(all_directorynames,newdirectorynames);
                if inhibconc(inhib) ==0
                    filenames_i = all_filenames(~contains(all_filenames,inhibname));
                    directorynames_i = all_directorynames(~contains(all_filenames,inhibname));
                else
                    filenames_i = all_filenames(contains(all_filenames,inhibstring));
                    directorynames_i = all_directorynames(contains(all_filenames,inhibstring));
                end
                filenames = filenames_i(~contains(filenames_i,'Hz'));
                directorynames = directorynames_i(~contains(filenames_i,'Hz'));
                
            end
            disp(filenames);
            
            flynumbers=cellfun(@(filename)regexp(filename,'fly\d+(\(|\_)','match'),filenames,'uni',false);
            
            fluo_all=cellfun(@(filename)extract_fluo(filename),filenames,'uni',false);
            fluomat_all=cell2mat(fluo_all);
            fluo_av=cellfun(@(directoryname1,flynumber1) average_within_fly(directorynames,flynumbers,fluomat_all,directoryname1,flynumber1),directorynames,flynumbers,'uni',false);
            fluomat_av=cell2mat(fluo_av);
            fluomat=unique(fluomat_av,'row');
            fluo=num2cell(fluomat,2);
            %-----------------------
            %calculating deltaF/F
            %-----------------------
            
            dff=calculate_dff(fluomat,baseline_start,baseline_end);
            numframes = size(dff,2);
            
            framenumbers=1:numframes;
            x=framenumbers/framerate;
            
            
            
            %make the figure name and path to output
            
            
            
            
            outputmatfile=fullfile(outputdir,(strcat(gender,'_',neuronpart,'_',inhibstring,'spontaneous.mat')));
            save(outputmatfile,'dff');
            
            
            
            
            
        end
    end
end
end
%-------------------------------------------------------
%function for checking if data are from the same animal
%--------------------------------------------------------
function average_event=average_within_fly(directorynames,flynumbers,fluo,directoryname1,flynumber1)

sames = cellfun(@(directoryname,flynumber)...
    (contains(directoryname,directoryname1) && contains(flynumber,flynumber1)),...
    directorynames,flynumbers);
%checking if both the flynumber and the directoryname in which the
%experiment was found is the same
total_fluo=fluo(sames,:);

average_event=mean(total_fluo,1);
end
