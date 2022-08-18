%Annika Rings, September 2019
%
%ODOURSTIM
%

function analyse_fluo_stim(foldername, varargin)

arguments = varargin;
%check if we really want 11 frames after pulse
options = struct('framerate', 5.92, ...
    'baseline', 6, ...
    'after_pulse', 11, ...
    'protocols', {{'ethanol'; 'acetic'}}, ...
    'genders', {{'_male'; 'female'; 'matedFemale'}}, ...
    'neuronparts', {{'medial'; 'lateral'}}, ...
    'resultsdir', 'Results', ...
    'multiroi', false, ...
    'numrois', 1, ...
    'roinames', {{}}, ...
    'inhibitor_conc', [0], ...
    'inhibitor_unit', 'uM', ...
    'inhibitor_names', {{'PTX'}}, ...
    'subfoldername', 'ROI', ...
    'stimdir', 'stim', ...
    'protocolname', '', ...
    'firstpulse', false, ...
    'pulseframe', 81, ...
    'eventdur', 180, ...
    'parallelize', true, ... % requires parallel computing toolbox
    'use_fluo', false, ...
    'stabilized', true, ...
    'stimtype', 'odour', ...
    'stimintensity', 1);
%------------------------------------------------------------------------
%setting optional key-value pair arguments
%-------------------------------------------------------------------------

%call the options_resolver function to check optional key-value pair
%arguments
[options, ~] = options_resolver(options, arguments, 'analyse_fluo_stim');

%this block gets all the values from the optional function arguments
%for all arguments that were not specified, the default is used


framerate = options.framerate; % frame rate in Hz
genders = options.genders;
neuronparts = options.neuronparts;
resultsdir = options.resultsdir;
multiroi = options.multiroi;
numrois = options.numrois;
protocols = options.protocols;
inhibconc = options.inhibitor_conc;
inhibunit = options.inhibitor_unit;
framerate = options.framerate; % frame rate in Hz
%consider extracting from tiff
inhibnames = options.inhibitor_names;
baseline = options.baseline; % in frames - currently unused
afterpulse = options.after_pulse; %in frames - for AUC
protocolname = options.protocolname;
roinames = options.roinames;
stimdir = options.stimdir;
firstpulse = options.firstpulse;
eventdur = options.eventdur;
parallelize = options.parallelize;
pulseframe = options.pulseframe;
use_fluo = options.use_fluo;
stabilized = options.stabilized;
stimtype = options.stimtype;
stimintensity = options.stimintensity;

startdir = pwd;
pathname = startdir;
subfoldername = options.subfoldername;
%must be a folder within the imaging folder

if ~multiroi

    numrois = 1; %set numrois to 1 if multiroi is false
end

%---------------------------------------------------------------------

%% determine if single folder or multiple folders should be analyzed
%---------------------------------------------------------------------

stackdir = fullfile(pathname, foldername, subfoldername);

if exist(stackdir, 'dir')

    outputdir = fullfile(pathname, '../', resultsdir);
    directories.name = fullfile(pathname, foldername);
    pathname = directories.name;
    directories.isdir = 1;
    issubdir = true;

else

    outputdir = fullfile(pathname, resultsdir);
    directories = dir(foldername);
    issubdir = false;

end
if ~exist(outputdir, 'dir')
    disp('Results folder does not exist. Ceating folder:')
    disp(outputdir);
    mkdir(fullfile(outputdir, '../'), resultsdir);
end

if (isempty(roinames))
    roinames = {'ROI'};
end
%-------------------------------------------------------
%the main loop
%-------------------------------------------------------

%loop through the roinames
for r = 1:size(roinames, 1)
    roiname = roinames{r};
    disp('ROI:')
    disp(roiname);
    %loop through the genders
    for g = 1:size(genders, 1)

        gender = genders{g};
        disp('now analysing:')
        disp(gender);
        %loop through the neuronparts
        for n = 1:size(neuronparts, 1)
            neuronpart = neuronparts{n};
            %loop through the protocols
            for o = 1:size(protocols, 1)
                protocol = protocols{o};
                %loop through inhibitor concentrations
                combo = zeros(length(inhibconc), 1);
                combo(end+1) = 1;
                if length(unique(inhibnames)) == 1
                    numinhibs = length(inhibconc);
                else
                    numinhibs = length(inhibconc) + 1;
                end

                for inhib = 1:numinhibs

                    if ~combo(inhib)
                        inhibname = inhibnames{inhib};
                        inhibstring = strcat(string(inhibconc(inhib)), ...
                            inhibunit, inhibname);
                    else

                        inhibname = strcat(inhibnames{:});
                        inhibstring = inhibname;
                    end
                    disp(inhibstring);

                    all_filenames = {};
                    all_directorynames = {};
                    all_stimfilenames = {};
                    %loop through directories
                    for p = 1:numel(directories)
                        if ~directories(p).isdir
                            continue;
                        end
                        if ismember(directories(p).name, ...
                                {'.', '..', '.DS_Store'})
                            continue;
                        end
                        if issubdir
                            directoryname = pathname;
                        else
                            directoryname = fullfile(pathname, ...
                                foldername, directories(p).name);


                        end

                        %the expected structure of the filenames
                        files = dir(char(strcat(directoryname, ...
                            '/', subfoldername, '/*', gender, ...
                            '*', neuronpart, '*', protocol, '*', ...
                            roiname, '*.*')));
                        newfilenames = arrayfun(@(f) fullfile(directoryname, ...
                            subfoldername, f.name), files, 'uni', false);
                        if stabilized
                            newstimfilenames = arrayfun(@(f) fullfile(directoryname, ...
                                stimdir, ...
                                strrep(f.name, ...
                                strcat('-stabilized', roiname), '_stim')), ...
                                files, 'uni', false);
                        else
                            newstimfilenames = arrayfun(@(f) fullfile(directoryname, ...
                                stimdir, ...
                                strrep(f.name, ...
                                roiname, '_stim')), ...
                                files, 'uni', false);
                        end
                        newdirectorynames = arrayfun(@(f) fullfile(directoryname), ...
                            files, 'uni', false);
                        all_filenames = vertcat(all_filenames, ...
                            newfilenames);
                        all_directorynames = vertcat(all_directorynames, ...
                            newdirectorynames);
                        all_stimfilenames = vertcat(all_stimfilenames, ...
                            newstimfilenames);
                        is_stimfilename = cellfun(@(stimname) isfile(stimname), ...
                            all_stimfilenames);

                        all_filenames_with_stim = all_filenames(is_stimfilename);
                        all_existing_stimfilenames = all_stimfilenames(is_stimfilename);
                        all_directorynames_with_stim = all_directorynames(is_stimfilename);
                        %if inhibitor_conc is 0, make sure the filename
                        %does not contain the inhibitorname. otherwise,
                        %find the concentration given in the filename
                        %this isn't great, as combinations of inhibitors
                        %are not detected so far.
                        if ~combo(inhib)
                            if inhibconc(inhib) == 0
                                filenames = all_filenames_with_stim;
                                directorynames = all_directorynames_with_stim;
                                stimfilenames = all_existing_stimfilenames;
                                for inhname = 1:length(inhibnames)
                                    directorynames = directorynames(~contains(filenames, ...
                                        inhibnames{inhname}));
                                    stimfilenames = stimfilenames(~contains(filenames, ...
                                        inhibnames{inhname}));
                                    filenames = filenames(~contains(filenames, ...
                                        inhibnames{inhname}));
                                end
                                inhibstring = '';
                            else
                                filenames = all_filenames_with_stim(contains(all_filenames_with_stim, ...
                                    inhibstring));
                                directorynames = all_directorynames_with_stim(contains(all_filenames_with_stim, ...
                                    inhibstring));
                                stimfilenames = all_existing_stimfilenames(contains(all_filenames_with_stim, ...
                                    inhibstring));
                                other_inhibs = setdiff(inhibnames, ...
                                    inhibname);
                                %make sure it doesn't contain
                                %the other inhibitors -
                                %combinations of inhibitors not supported!
                                for inhname = 1:length(other_inhibs)
                                    directorynames = directorynames(~contains(filenames, ...
                                        other_inhibs{inhname}));
                                    stimfilenames = stimfilenames(~contains(filenames, ...
                                        other_inhibs{inhname}));
                                    filenames = filenames(~contains(filenames, ...
                                        other_inhibs{inhname}));
                                end

                            end
                        else
                            filenames = all_filenames_with_stim;
                            directorynames = all_directorynames_with_stim;
                            stimfilenames = all_existing_stimfilenames;
                            other_inhibs = setdiff(inhibnames, inhibname);

                            for inhname = 1:length(other_inhibs)
                                directorynames = directorynames(contains(filenames, ...
                                    other_inhibs{inhname}));
                                stimfilenames = stimfilenames(contains(filenames, ...
                                    other_inhibs{inhname}));
                                filenames = filenames(contains(filenames, ...
                                    other_inhibs{inhname}));
                            end

                        end
                    end


                    if size(all_stimfilenames, 1) ~= size(all_existing_stimfilenames, 1)
                        disp('WARNING: these stimfiles were missing:');
                        disp(setdiff(all_stimfilenames, ...
                            all_existing_stimfilenames));

                    end
                    if (~isempty(filenames))
                        disp('analyzing files:')
                        disp(filenames);


                        %find flynumber: based on a regular expression,
                        %expecting the flynumber to be preceeded by
                        %the string
                        %'fly' and followed either by a ( or _
                        flynumbers = cellfun(@(filename)regexp(filename, ...
                            'fly\d+(\(|\_)', 'match'), ...
                            filenames, 'uni', false);
                        %extract fluorescence for all files using the
                        % (external) extract_fluo function
                        if use_fluo
                            fluo_all = cellfun(@(filename)load_fluo(filename), ...
                                filenames, 'uni', false);
                            stimuli = cellfun(@(sfilename)load_fluo(sfilename), ...
                                stimfilenames, ...
                                'uni', false);
                        else

                            fluo_all = cellfun(@(filename)extract_fluo(filename, ...
                                parallelize), ...
                                filenames, 'uni', false);
                            stimuli = cellfun(@(sfilename)extract_fluo(sfilename, ...
                                parallelize), ...
                                stimfilenames, ...
                                'uni', false);
                        end
                        isStimframe = cellfun(@(stim) stim > stimintensity, stimuli, ...
                            'uni', false);

                        pulsestartframes = cellfun(@(isStim) strfind(isStim, ...
                            [0, 1]), isStimframe, ...
                            'uni', false);
                        pulsesendframes = cellfun(@(isStim) strfind(isStim, ...
                            [1, 0]), isStimframe, ...
                            'uni', false);


                        n = 1;
                        while isempty(pulsesendframes{n})

                            n = n + 1;
                        end
                        pulsedur = pulsesendframes{n}(1) - pulsestartframes{n}(1);

                        switch stimtype
                            case 'odour'

                                if firstpulse
                                    pulseaverage_dff_all = cellfun(@(f, ...
                                        pulsestarts) average_pulses_odour(f, ...
                                        first_nonempty(pulsestarts), ...
                                        1, pulseframe, eventdur), ...
                                        fluo_all, pulsestartframes, ...
                                        'uni', false);
                                else


                                    pulseaverage_dff_all = cellfun(@(f, pulsestarts) average_pulses_odour(f, ...
                                        pulsestarts, 1, pulseframe, eventdur), ...
                                        fluo_all, pulsestartframes, ...
                                        'uni', false);
                                end

                            case 'LED'
                                if firstpulse
                                    pulseaverage_dff_all = cellfun(@(f, ...
                                        pulsestarts) average_pulses_shorter(f, ...
                                        first_nonempty(pulsestarts), ...
                                        1), ...
                                        fluo_all, pulsestartframes, ...
                                        'uni', false);
                                else


                                    pulseaverage_dff_all = cellfun(@(f, ...
                                        pulsestarts) average_pulses_shorter(f, pulsestarts, 1), ...
                                        fluo_all, pulsestartframes, ...
                                        'uni', false);
                                end
                            otherwise
                                if firstpulse
                                    pulseaverage_dff_all = cellfun(@(f, ...
                                        pulsestarts) average_pulses(f, ...
                                        first_nonempty(pulsestarts), ...
                                        1), ...
                                        fluo_all, pulsestartframes, ...
                                        'uni', false);
                                else


                                    pulseaverage_dff_all = cellfun(@(f, ...
                                        pulsestarts) average_pulses(f, pulsestarts, 1), ...
                                        fluo_all, pulsestartframes, ...
                                        'uni', false);
                                end
                        end
                        pulseavmat = cell2mat(pulseaverage_dff_all);
                        %average all experiments from the same fly
                        %(i.e. have the same fly number and the same
                        %directory name)

                        [fluo_av, flyidentifiers] = cellfun(@(directoryname1, ...
                            flynumber1) average_within_fly(directorynames, ...
                            flynumbers, pulseavmat, directoryname1, flynumber1), ...
                            directorynames, flynumbers, ...
                            'uni', false);

                        fluomat_av = cell2mat(fluo_av);
                        fluomat_nonempty = rmmissing(fluomat_av);
                        flyidentifiers_nonempty = flyidentifiers(all(~isnan(fluomat_av), 2));
                        fluomat = unique(fluomat_nonempty, ...
                            'row', 'stable');
                        pulseaverage_dff = num2cell(fluomat, 2);
                        uniqueflies = unique(flyidentifiers_nonempty, ...
                            'stable');


                        %calculating mean, n and SEM of dff

                        n_flies = size(pulseaverage_dff, 1) / numrois;
                        n_rois = size(pulseaverage_dff, 1);

                        mean_pulseav_dff = mean(fluomat, 1);
                        SEM_pulseav_dff = std(fluomat) ./ n_flies;
                        %check if raw fluorescence needs to be used here.
                        dff_of_pulses = cellfun(@(f)AUC_dff(f, ...
                            pulseframe, pulsedur, framerate, afterpulse), ...
                            pulseaverage_dff, ...
                            'uni', false);
                        %arguments to AUC_pulse are in frames, not seconds
                        pulsedff = cell2mat(dff_of_pulses);


                        outputfig2 = fullfile(outputdir, (strcat(gender, ...
                            '_', neuronpart, inhibstring, '_', ...
                            protocol, '_', roiname, '_mean_pulse.eps')));
                        fignew2 = figure('Name', strcat(gender, '_', ...
                            neuronpart, inhibstring, '_', ...
                            protocol, '_', roiname, '_mean_pulse'));
                        %plot the mean with a shaded area showing the SEM
                        x2 = 1:size(mean_pulseav_dff, 2);
                        times = (x2 - 1) / framerate;
                        h = boundedline(times, (transpose(mean_pulseav_dff)), ...
                            transpose(SEM_pulseav_dff), 'k');
                        xlim([times(1), times(end)]);
                        ylim([-0.2, 0.8])

                        hpatch2 = patch(([pulseframe, ...
                            pulsedur + pulseframe, ...
                            pulsedur + pulseframe, pulseframe] - 1)./framerate, ...
                            [min(ylim) * [1, 1], max(ylim) * [1, 1]], ...
                            'r', 'EdgeColor', 'none');
                        %send the shaded area to the back of the graph
                        uistack(hpatch2, 'bottom');

                        saveas(fignew2, outputfig2, 'epsc');

                        %save data to a .mat file
                        outputmatfile = fullfile(outputdir, ...
                            (strcat(gender, '_', neuronpart, ...
                            protocolname, inhibstring, '_', protocol, ...
                            '_', roiname, '.mat')));
                        save(outputmatfile, 'pulsedff', ...
                            'n_flies', 'mean_pulseav_dff', ...
                            'SEM_pulseav_dff', 'uniqueflies', 'fluomat');
                    end

                end
            end
        end


    end
end
cd(startdir);

function first_or_empty = first_nonempty(m)
if isempty(m)
    first_or_empty = [];
else first_or_empty = m(1);
end
