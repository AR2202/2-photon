%Annika Rings, 2021
%LED_STIM
function LED_stim(foldername, varargin)


%------------------------------------------------------------------------

%% optional key-value pair arguments and their defaults
%------------------------------------------------------------------------
options = struct('framerate', 5.92, 'baseline', 6, 'after_pulse', 6, ...
    'genders', {{'_male'; '_female'}}, ...
    'neuronparts', {{'medial'; 'lateral'}}, ...
    'resultsdir', 'Results', 'multiroi', false, 'numrois', 1, ...
    'roinames', {{}}, ...
    'inhibitor_conc', [0], ...
    'inhibitor_unit', 'uM', ...
    'inhibitor_names', {{'PTX'}}, ...
    'subfoldername', 'ROI', 'stimdir', 'stim', ...
    'protocolname', '_4pulse_5s');
arguments = varargin;

%------------------------------------------------------------------------

%% setting optional key-value pair arguments
%-------------------------------------------------------------------------

%call the options_resolver function to check optional key-value pair
%arguments
[options, ~] = options_resolver(options, arguments, 'LED_Stim');

%this block gets all the values from the optional function arguments
%for all arguments that were not specified, the default is used


framerate = options.framerate; % frame rate in Hz
%consider extracting from tiff
genders = options.genders;
neuronparts = options.neuronparts;
resultsdir = options.resultsdir;
multiroi = options.multiroi;
numrois = options.numrois;
stimdir = options.stimdir;
inhibconc = options.inhibitor_conc;
inhibnames = options.inhibitor_names;
inhibunit = options.inhibitor_unit;
baseline = options.baseline; % in frames - currently unused
afterpulse = options.after_pulse; %in frames - for AUC
protocolname = options.protocolname;
roinames = options.roinames;


pulseframe = 61; % this is the frame in which the pulse comes, based
%on the average_pulses_shorter function. Needs to be changed if a different
%function is used
%pulsetime = pulseframe / framerate;
%this is the time for the individual pulse in the average

%     pulsetimes = stimstarts ./ framerate;


startdir = pwd;
pathname = startdir;
subfoldername = options.subfoldername; %must be a folder within the imaging folder

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

%% the main loop
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
                    inhibstring = strcat(string(inhibconc(inhib)), inhibunit, inhibname);
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
                    if ismember(directories(p).name, {'.', '..', '.DS_Store'})
                        continue;
                    end
                    if issubdir
                        directoryname = pathname;
                    else
                        directoryname = fullfile(pathname, foldername, directories(p).name);


                    end
                    %the expected structure of the filenames
                    files = dir(char(strcat(directoryname, '/', subfoldername, '/*', gender, '*', neuronpart, '*', protocolname, '*', roiname, '*.tif')));
                    newfilenames = arrayfun(@(f) fullfile(directoryname, subfoldername, f.name), files, 'uni', false);
                    newstimfilenames = arrayfun(@(f) fullfile(directoryname, stimdir, strrep(f.name, strcat('-stabilized', roiname), '_stim')), files, 'uni', false);
                    newdirectorynames = arrayfun(@(f) fullfile(directoryname), files, 'uni', false);
                    all_filenames = vertcat(all_filenames, newfilenames);
                    all_directorynames = vertcat(all_directorynames, newdirectorynames);
                    all_stimfilenames = vertcat(all_stimfilenames, newstimfilenames);
                    is_stimfilename = cellfun(@(stimname) isfile(stimname), all_stimfilenames);

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
                                directorynames = directorynames(~contains(filenames, inhibnames{inhname}));
                                stimfilenames = stimfilenames(~contains(filenames, inhibnames{inhname}));
                                filenames = filenames(~contains(filenames, inhibnames{inhname}));
                            end
                            inhibstring = '';
                        else
                            filenames = all_filenames_with_stim(contains(all_filenames_with_stim, inhibstring));
                            directorynames = all_directorynames_with_stim(contains(all_filenames_with_stim, inhibstring));
                            stimfilenames = all_existing_stimfilenames(contains(all_filenames_with_stim, inhibstring));
                            other_inhibs = setdiff(inhibnames, inhibname);
                            %make sure it doesn't contain the other inhibitors -
                            %combinations of inhibitors not supported!
                            for inhname = 1:length(other_inhibs)
                                directorynames = directorynames(~contains(filenames, other_inhibs{inhname}));
                                stimfilenames = stimfilenames(~contains(filenames, other_inhibs{inhname}));
                                filenames = filenames(~contains(filenames, other_inhibs{inhname}));
                            end

                        end
                    else
                        filenames = all_filenames_with_stim;
                        directorynames = all_directorynames_with_stim;
                        stimfilenames = all_existing_stimfilenames;
                        other_inhibs = setdiff(inhibnames, inhibname);

                        for inhname = 1:length(other_inhibs)
                            directorynames = directorynames(contains(filenames, other_inhibs{inhname}));
                            stimfilenames = stimfilenames(contains(filenames, other_inhibs{inhname}));
                            filenames = filenames(contains(filenames, other_inhibs{inhname}));
                        end

                    end
                end

                if size(all_stimfilenames, 1) ~= size(all_existing_stimfilenames, 1)
                    disp('WARNING: these stimfiles were missing:');
                    disp(setdiff(all_stimfilenames, all_existing_stimfilenames));

                end
                if (~isempty(filenames))
                    disp('analyzing files:')
                    disp(filenames);


                    %find flynumber: based on a regular expression,
                    %expecting the flynumber to be preceeded by the string
                    %'fly' and followed either by a ( or _
                    flynumbers = cellfun(@(filename)regexp(filename, 'fly\d+(\(|\_)', 'match'), filenames, 'uni', false);
                    %extract fluorescence for all files using the (external) extract_fluo
                    %function
                    fluo_all = cellfun(@(filename)extract_fluo(filename), filenames, 'uni', false);
                    stimuli = cellfun(@(sfilename)extract_fluo(sfilename), stimfilenames, 'uni', false);
                    isStimframe = cellfun(@(stim) stim > 1, stimuli, 'uni', false);
                    pulsestartframes = cellfun(@(isStim) strfind(isStim, [0, 1]), isStimframe, 'uni', false);
                    pulsesendframes = cellfun(@(isStim) strfind(isStim, [1, 0]), isStimframe, 'uni', false);


                    pulsedur = pulsesendframes{1}(1) - pulsestartframes{1}(1);


                    pulseaverage_dff_all = cellfun(@(f, pulsestarts) average_pulses_shorter(f, pulsestarts, 1), fluo_all, pulsestartframes, 'uni', false);
                    pulseavmat = cell2mat(pulseaverage_dff_all);
                    %average all experiments that come from the same fly
                    %(i.e. have the same fly number and the same directory
                    %name)
                    [fluo_av, flyidentifiers] = cellfun(@(directoryname1, flynumber1) average_within_fly(directorynames, flynumbers, pulseavmat, directoryname1, flynumber1), directorynames, flynumbers, 'uni', false);
                    fluomat_av = cell2mat(fluo_av);
                    fluomat_nonempty = rmmissing(fluomat_av);
                    flyidentifiers_nonempty = flyidentifiers(all(~isnan(fluomat_av), 2));
                    fluomat = unique(fluomat_nonempty, 'row', 'stable');
                    pulseaverage_dff = num2cell(fluomat, 2);
                    uniqueflies = unique(flyidentifiers_nonempty, 'stable');
                    %
                    %first pulses
                    % firstpulse_dff = cellfun(@(f) average_pulses(f, pulsetimes(1), framerate), fluo, 'uni', false);
                    % firstmat = cell2mat(firstpulse_dff);
                    %last pullses
                    %lastpulse_dff = cellfun(@(f) average_pulses(f, pulsetimes(size(pulsetimes, 2)), framerate), fluo, 'uni', false);
                    %lastmat = cell2mat(lastpulse_dff);


                    %calculating mean, n and SEM of dff

                    n_flies = size(pulseaverage_dff, 1) / numrois;
                    n_rois = size(pulseaverage_dff, 1);

                    mean_pulseav_dff = mean(fluomat, 1);
                    SEM_pulseav_dff = std(fluomat) ./ n_flies;
                    %check if raw fluorescence needs to be used here.
                    dff_of_pulses = cellfun(@(f)AUC_dff(f, pulseframe, pulsedur, framerate, afterpulse), pulseaverage_dff, 'uni', false);
                    %arguments to AUC_pulse are in frames, not seconds
                    pulsedff = cell2mat(dff_of_pulses);


                    outputfig2 = fullfile(outputdir, (strcat(gender, '_', neuronpart, inhibstring, roiname, '_mean_pulse.eps')));
                    fignew2 = figure('Name', strcat(gender, '_', neuronpart, inhibstring, roiname, '_mean_pulse'));
                    %plot the mean with a shaded area showing the SEM
                    x2 = 1:150;
                    h = boundedline(x2, (transpose(mean_pulseav_dff)), transpose(SEM_pulseav_dff), 'k');
                    xlim([0, 150]);
                    ylim([-0.2, 0.8])

                    hpatch2 = patch([pulseframe, pulsedur + pulseframe, pulsedur + pulseframe, pulseframe], [min(ylim) * [1, 1], max(ylim) * [1, 1]], 'r', 'EdgeColor', 'none');
                    %send the shaded area to the back of the graph
                    uistack(hpatch2, 'bottom');

                    saveas(fignew2, outputfig2, 'epsc');

                    %save data to a .mat file
                    outputmatfile = fullfile(outputdir, (strcat(gender, '_', neuronpart, protocolname, inhibstring, roiname, '.mat')));
                    save(outputmatfile, 'pulsedff', 'n_flies', 'mean_pulseav_dff', 'SEM_pulseav_dff', 'uniqueflies', 'fluomat');
                end
            end
        end

    end
end
cd(startdir);
