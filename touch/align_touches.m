%Annika Rings January 2019
%ALIGN_TOUCHES: is a function for reading in touchtimes files from specified 'touchdir' directory
%It then reads in corresponding imaging results F from another
%directory specified as 'resultsdir'
%Touch events are defined
%for each touch event, corresponding fluorescence data are found. The
%events are aligned. They are then averaged per experiment and experiment
%results are averaged for each species.
%they are plotted separately for male, virgin female and mated female experimental flies.
%they are expected to contain the following strings in the filenames for
%recognition:
%'_male_fly': for experimental male
%'_female_fly': for experimental virgin female
%'matedF_fly': for mated female experimental flies
%reduced touchtimes are supported: only the start and the end of each touch
%period are specified on the excel table
%alternative: specify all touch frames
%use of reduced touchtimes option requires the name of touch directory to
%contain the string 'reduced'
%the otpional 'reduced' keyword argument can also be used to specify
%whether the reduced or complete touchtimes format was used by setting
%'reduced' to either true or false. This overrides determining the
%touchtimes format by directory name and can be used independent of the directory
%name
%takes no required arguments
%optional arguments are:
%framerate: in Hz, default: 5.92
%numframes: number of frames in imaging, default: 600
% touchdir: The folder where the touchtimes files are located
% resultsdir :The folder where the results of single experiments are located
% outputdirmean: output directory for average
% outputdirsingles:outputdirectory for single experiment plots (disabled at
% the moment)
%basetime: length of baseline, default: 10s eventtime: length of an event
%(after the touch), default: 20s
%intervaltime: length of minimum interval
%between touches, default: 10s
%excludedoubles: whether touches on both
%sides in a short timeperiod should be excluded. Default: false
% filterstring : a string by which exps should be filtered
%this can be a specific part of the neuron imaged form
%dependencies:
%-options_resolver.m
%-boundedline.m

function align_touches(varargin)
options = struct( ...
    'framerate', 5.92, ...
    'numframes', 600, ...
    'touchdir', 'touchtimes', ...
    'resultsdir', 'Results', ...
    'outputdirmean', 'Results', ...
    'outputdir_singles', 'Results_single_exp', ...
    'basetime', 10, ...
    'eventtime', 20, ...
    'intervaltime', 10, ...
    'excludedoubles', 0, ...
    'filterstring', '', ...
    'reduced', false);
arguments = varargin;

%call the options_resolver function to check optional key-value pair
%arguments

[options, override_reduced] = options_resolver(options, arguments, 'align_touches');

%setting the values for optional arguments

framerate = options.framerate;
numframes = options.numframes;
touchdir = options.touchdir;
resultsdir = options.resultsdir;
outputdirmean = options.outputdirmean;
reduced = options.reduced;
intervaltime = options.intervaltime;
basetime = options.basetime;
eventtime = options.eventtime;
excludedoubles = options.excludedoubles;
filterstring = options.filterstring;

%This part of the script reads in the data
currentdir = pwd;
lateralized = 0;
if contains(touchdir, '_l_r_') || contains(touchdir, '_r_l_')
    lateralized = 1;
end

options.lateralized = lateralized;
if ~override_reduced
    if contains(touchdir, 'reduced')
        reduced = 1;
    else
        reduced = 0;
    end
end

%go to touchdirectory

cd(touchdir)

%get filenames form the directory

files = dir('*.xlsx');

files = {files.name};
%read in all the touchtimes from the files

touchtimes = cellfun(@(filename) table2array( ...
    readtable(filename, 'Range', 'E:E', 'ReadVariableNames', 1)), ...
    files, 'UniformOutput', false);

if lateralized
    touchtimes_r = cellfun(@(filename) table2array( ...
        readtable(filename, 'Range', 'I:I', 'ReadVariableNames', 1)), ...
        files, 'UniformOutput', false);
else
    touchtimes_r = touchtimes;
end
%check if reduced touchtimes format was used
%if so, create complete touchtimes table from the reduced one

if reduced
    disp('reduced touchtime format was used.');
    touchtimes = cellfun(@(testtimes) expand_reduced_touchtimes(testtimes), ...
        touchtimes, 'UniformOutput', false);
    touchtimes_r = cellfun(@(testtimes) expand_reduced_touchtimes(testtimes), ...
        touchtimes_r, 'UniformOutput', false);

end

%find out the string from the touchtimes filename which also appears in the
%resultsfile
resultfilestrings = cellfun(@(filename) ...
    strrep((regexprep(filename, '_(\d+).xlsx', '_')), 'touchtimes_', ''), ...
    files, 'UniformOutput', false);
%find out the file number from the filename

numberstrings = cellfun(@(filename) ...
    strrep((regexprep(filename, 'touchtimes_(\d+)_(\d+)_(\d+)_', '')), '.xlsx', ''), ...
    files, 'UniformOutput', false);

%go back into the start directory and then into the results directory
cd(currentdir);
cd(resultsdir);

%make an array of all resultsfiles containing the string
resultfiles = cellfun(@(resultfilestring) ...
    dir(strcat(resultfilestring, '*.xlsx')), ...
    resultfilestrings, 'UniformOutput', false);

resultfiles = cellfun(@(resultfile) ...
    {resultfile.name}, resultfiles, 'UniformOutput', false);


resultfilenames = cellfun(@(resultfile) resultfile, ...
    {resultfiles}, 'UniformOutput', false);

%find out the experiment names from the files
expnames = cellfun(@(resultfile) cellfun(@(resultf) ...
    table2array(readtable(resultf, 'Sheet', 'Sheet2', 'ReadVariableNames', 0)), ...
    resultfile, 'UniformOutput', false), resultfiles, 'UniformOutput', false);
%find the experiment number in the experiment names

foundstr = cellfun(@(numbers, files) cellfun(@(resultsfiles) ...
    cellfun(@(exp) contains(exp, numbers), resultsfiles), ...
    files, 'UniformOutput', false), ...
    numberstrings, expnames, 'UniformOutput', false);

[found] = cellfun(@(numbers, files) cellfun(@(resultsfiles) ...
    cellfun(@(exp) foundstringnames(exp, numbers), resultsfiles, 'Uniformoutput', false), ...
    files, 'UniformOutput', false), numberstrings, expnames, 'UniformOutput', false);

[foundin, foundfilename, fileindex] = cellfun(@(exps, nums, rfiles) ...
    foundInWhich(exps, nums, rfiles), ...
    expnames, numberstrings, resultfiles, 'UniformOutput', false);

imagingfilestrings = foundfilename;

all_expresults = cellfun(@(foundname, foundindex) ...
    resultfinder(foundname, foundindex{1, 1}), ...
    foundin, fileindex, 'UniformOutput', false);

%make an array containing data from touchtimes and corresponding fluo

data_array = cellfun(@(data1, data2, filename, resultname, data3) ...
    {transpose(data1), transpose(data2), transpose(filename), transpose(resultname), transpose(data3)}, ...
    touchtimes, all_expresults, foundfilename, foundin, touchtimes_r, 'UniformOutput', false);
data_array = transpose(data_array);

%make a second one for left vs right touch
data_array_swapped = cellfun(@(data1, data2, filename, resultname, data3) ...
    {transpose(data1), transpose(data2), transpose(filename), transpose(resultname), transpose(data3)}, ...
    touchtimes_r, all_expresults, foundfilename, foundin, touchtimes, 'UniformOutput', false);
data_array_swapped = transpose(data_array_swapped);


%This part of the script defines the events, aligns them and performs the
%calculations
%-------------------------------------------------------------------------

%call the main function 'find_touch_events' on both the ipsi and contra-
%lateral data array
[touchstartframes, eventsmat, eventpeaks_dff, eventpeaks_mean, eventpeaks_SEM, mean_event, SEM_event, touchtimes, fluo, x_events, eventsmat_peak_aligned] ...
    = cellfun(@(data_arr) find_touch_events(data_arr, options), ...
    data_array, 'UniformOutput', false);

[touchstartframes_contra, eventsmat_contra, eventpeaks_dff_contra, eventpeaks_mean_contra, eventpeaks_SEM_contra, mean_event_contra, SEM_event_contra, touchtimes_contra, fluo_contra, x_events_contra, eventsmat_peak_aligned_contra] ...
    = cellfun(@(data_arr) find_touch_events(data_arr, options), ...
    data_array_swapped, 'UniformOutput', false);

t_foundfilename = transpose(foundfilename);
t_foundin = transpose(foundin);
%handling missing values (NaNs)
%---------------------------------------------------------------------
eventpeaks_mean = cellfun(@(ev) standardizeMissing(ev, 0), eventpeaks_mean);
eventpeaks_mean = standardizeMissing(eventpeaks_mean, Inf);
mean_event = cellfun(@(ev) standardizeMissing(ev, 0), mean_event, 'uni', false);
eventsmat = cellfun(@(ev) standardizeMissing(ev, 0), eventsmat, 'uni', false);

eventpeaks_mean_contra = cellfun(@(ev) standardizeMissing(ev, 0), eventpeaks_mean_contra);
mean_event_contra = cellfun(@(ev) standardizeMissing(ev, 0), mean_event_contra, 'uni', false);
eventsmat_contra = cellfun(@(ev) standardizeMissing(ev, 0), eventsmat_contra, 'uni', false);

%taking averages within one fly first, treating them as only one experiment
%--------------------------------------------------------------------------
average_event = cellfun(@(foundinfilename, foundinfile) ...
    average_within_fly(foundfilename, foundin, eventsmat, foundinfilename{1}, foundinfile), ...
    foundfilename, foundin, 'uni', false);

average_event_contra = cellfun(@(foundinfilename, foundinfile) ...
    average_within_fly(foundfilename, foundin, eventsmat_contra, foundinfilename{1}, foundinfile), ...
    foundfilename, foundin, 'uni', false);


average2mat = transpose(cell2mat(average_event));
average2mat_contra = transpose(cell2mat(average_event_contra));

average_event_peak_aligned = cellfun(@(foundinfilename, foundinfile) ...
    average_within_fly(foundfilename, foundin, eventsmat_peak_aligned, foundinfilename{1}, foundinfile), ...
    foundfilename, foundin, 'uni', false);

average_event_peak_aligned_contra = cellfun(@(foundinfilename, foundinfile) ...
    average_within_fly(foundfilename, foundin, eventsmat_peak_aligned_contra, foundinfilename{1}, foundinfile), ...
    foundfilename, foundin, 'uni', false);


average2mat_peak_aligned = transpose(cell2mat(average_event_peak_aligned));
average2mat_peak_aligned_contra = transpose(cell2mat(average_event_peak_aligned_contra));

eventpeaks_dff_transposed = cellfun(@(evpeak) transpose(evpeak), eventpeaks_dff, 'UniformOutput', false);
eventpeaks_dff_transposed_contra = cellfun(@(evpeak) transpose(evpeak), eventpeaks_dff_contra, 'UniformOutput', false);
average_eventpeak = cellfun(@(foundinfilename, foundinfile) ...
    average_within_fly(foundfilename, foundin, eventpeaks_dff_transposed, foundinfilename{1}, foundinfile), ...
    foundfilename, foundin, 'uni', false);

average_eventpeak_contra = cellfun(@(foundinfilename, foundinfile) ...
    average_within_fly(foundfilename, foundin, eventpeaks_dff_transposed_contra, foundinfilename{1}, foundinfile), ...
    foundfilename, foundin, 'uni', false);


average_peak_mat = transpose(cell2mat(average_eventpeak));
average_peak_mat_contra = transpose(cell2mat(average_eventpeak_contra));

%This part of the script averages over the experiments of each sex
%--------------------------------------------------------------------------
combinedtable_unfiltered ...
    = table(average_peak_mat, mean_event, t_foundfilename, t_foundin, eventsmat, average2mat, average2mat_peak_aligned);
combinedtable_contra_unfiltered ...
    = table(average_peak_mat_contra, mean_event_contra, t_foundfilename, t_foundin, eventsmat_contra, average2mat_contra, average2mat_peak_aligned_contra);

%find the male experimental flies
combinedtable ...
    = combinedtable_unfiltered(contains(string(combinedtable_unfiltered.t_foundfilename), filterstring), :);
combinedtable_contra ...
    = combinedtable_contra_unfiltered(contains(string(combinedtable_contra_unfiltered.t_foundfilename), filterstring), :);
combinedtable ...
    = rmmissing(combinedtable);
combinedtable_contra ...
    = rmmissing(combinedtable_contra);
flytypes = {'_male_fly', '_female_fly', '_mated_female_fly'};
for i = 1:numel(flytypes)

    flytype = flytypes{i};
    flytypepart = strrep(strrep(flytype, '_', ''), 'fly', '');
    figurename = strcat(flytypepart, '_mean_event');
    dataname = strcat('mean_', flytypepart, '_touch.mat');

    combinedtable_male ...
        = combinedtable(contains(string(combinedtable.t_foundfilename), flytype), :);
    combinedtable_male_contra ...
        = combinedtable_contra(contains(string(combinedtable_contra.t_foundfilename), flytype), :);

    %extract the different species from the table

    %for ipsilateral touches

    maletable_m ...
        = combinedtable_male(contains(string(combinedtable_male.t_foundin), ''), :);

    %contralateral touches

    maletable_m_contra ...
        = combinedtable_male_contra(contains(string(combinedtable_male_contra.t_foundin), ''), :);


    %convert the tables to cell arrays
    %ipsi

    maledata_m = table2cell(maletable_m);

    %contra


    maledata_m_contra = table2cell(maletable_m_contra);


    %mean of male touching  male
    %-------------------------------------

    cell_mean_eventpeak_m = transpose(rmmissing(unique(maletable_m.average_peak_mat, 'rows')));

    male_eventpeaks_mean_m = mean(cell_mean_eventpeak_m, 2);
    male_eventpeaks_SEM_m = std(cell_mean_eventpeak_m, 0, 2) / sqrt(size(cell_mean_eventpeak_m, 2));


    cell_mean_event_m = transpose(rmmissing(unique(maletable_m.average2mat, 'rows')));

    male_mean_event_m = mean(cell_mean_event_m, 2);
    male_SEM_event_m = std(cell_mean_event_m, 0, 2) / sqrt(size(cell_mean_event_m, 2));

    cell_mean_event_m_contra = transpose(rmmissing(unique(maletable_m_contra.average2mat_contra, 'rows')));
    male_mean_event_m_contra = mean(cell_mean_event_m_contra, 2);
    male_SEM_event_m_contra = std(cell_mean_event_m_contra, 0, 2) / sqrt(size(cell_mean_event_m_contra, 2));

    cell_mean_event_peak_aligned_m = transpose(rmmissing(unique(maletable_m.average2mat_peak_aligned, 'rows')));

    male_mean_event_peak_aligned_m = mean(cell_mean_event_peak_aligned_m, 2);
    male_SEM_event_peak_aligned_m = std(cell_mean_event_peak_aligned_m, 0, 2) / sqrt(size(cell_mean_event_peak_aligned_m, 2));

    cell_mean_event_peak_aligned_m_contra = transpose(rmmissing(unique(maletable_m_contra.average2mat_peak_aligned_contra, 'rows')));
    male_mean_event_peak_aligned_m_contra = mean(cell_mean_event_peak_aligned_m_contra, 2);
    male_SEM_event_peak_aligned_m_contra = std(cell_mean_event_peak_aligned_m_contra, 0, 2) / sqrt(size(cell_mean_event_peak_aligned_m_contra, 2));


    cell_mean_eventpeak_m_contra = transpose(rmmissing(unique(maletable_m_contra.average_peak_mat_contra, 'rows')));

    male_eventpeaks_mean_m_contra = mean(cell_mean_eventpeak_m_contra, 2);
    male_eventpeaks_SEM_m_contra = std(cell_mean_eventpeak_m_contra, 0, 2) / sqrt(size(cell_mean_eventpeak_m_contra, 2));


    %make the x-values for the plot
    %-------------------------
    xevents_nonempty = x_events(~cellfun(@(cell) isempty (cell), x_events));
    xevents_nonempty_contra = x_events_contra(~cellfun(@(cell) isempty (cell), x_events_contra));
    cd(currentdir);


    %plot the mean event of male
    %------------------------------
    %-------------------------------

    if lateralized
        try
            ipsiname = strcat(figurename, '_ipsi');
            ipsidataname = strrep(dataname, '.mat', '_ipsi.amt');
            fignew = figure('Name', ipsiname);
            %requires package boundedline
            plot_male_event_m = boundedline(xevents_nonempty{1, 1}, male_mean_event_m, male_SEM_event_m, 'm');
            plot_male_event_peak_aligned_m = boundedline(xevents_nonempty_contra{1, 1}, male_mean_event_peak_aligned_m, male_SEM_event_peak_aligned_m, 'c');

            cd(outputdirmean);
            saveas(fignew, ipsiname, 'epsc');
            save(ipsidataname, 'male_mean_event_m', 'male_SEM_event_m', 'male_mean_event_peak_aligned_m', 'male_SEM_event_peak_aligned_m', 'male_eventpeaks_mean_m', 'male_eventpeaks_SEM_m', 'cell_mean_eventpeak_m');

        catch ME
            errorMessage = ME.message;
            disp(errorMessage);
        end
        cd(currentdir);
        try
            contraname = strcat(figurename, '_contra');
            contradataname = strrep(dataname, '.mat', '_contra.mat');
            fignew = figure('Name', ipsiname);
            fignew = figure('Name', contraname);
            %requires package boundedline
            plot_male_event_m_contra = boundedline(xevents_nonempty_contra{1, 1}, male_mean_event_m_contra, male_SEM_event_m_contra, 'm');
            cd(outputdirmean);
            saveas(fignew, contraname, 'epsc');
            save(contradataname, 'male_mean_event_m_contra', 'male_SEM_event_m_contra', 'male_mean_event_peak_aligned_m_contra', 'male_SEM_event_peak_aligned_m-contra', 'male_eventpeaks_mean_m_contra', 'male_eventpeaks_SEM_m_contra', 'cell_mean_eventpeak_m_contra');

        catch ME
            errorMessage = ME.message;
            disp(errorMessage);
        end
        cd(currentdir);


    else

        try
            fignew = figure('Name', figurename);
            %requires package boundedline
            plot_male_event_m = boundedline(xevents_nonempty{1, 1}, male_mean_event_m, male_SEM_event_m, 'm');
            plot_male_event_peak_aligned_m = boundedline(xevents_nonempty_contra{1, 1}, male_mean_event_peak_aligned_m, male_SEM_event_peak_aligned_m, 'c');

            cd(outputdirmean);
            saveas(fignew, figurename, 'epsc');
            save(dataname, 'male_mean_event_m', 'male_SEM_event_m', 'male_mean_event_peak_aligned_m', 'male_SEM_event_peak_aligned_m', 'male_eventpeaks_mean_m', 'male_eventpeaks_SEM_m', 'cell_mean_eventpeak_m');

        catch ME
            errorMessage = ME.message;
            disp(errorMessage);
        end

        cd(currentdir);
    end
    try
        cd(outputdirmean);
        save('x_events.mat', 'xevents_nonempty');
    catch ME
        errorMessage = ME.message;
        disp(errorMessage);
    end
    cd(currentdir);
end
end
%This part is the definition of the functions used in the previous parts of
%the script.

function [touchstartframes, eventsmat, eventpeaks_dff, eventpeaks_mean, eventpeaks_SEM, mean_event, SEM_event, touchtimes, fluo, x_events, eventsmat_peak_aligned] ...
    = find_touch_events(data, options)
framerate = options.framerate;
numframes = options.numframes;
touchdir = options.touchdir;
resultsdir = options.resultsdir;
outputdirmean = options.outputdirmean;
reduced = options.reduced;
intervaltime = options.intervaltime;
basetime = options.basetime;
eventtime = options.eventtime;
excludedoubles = options.excludedoubles;
filterstring = options.filterstring;
lateralized = options.lateralized;

if lateralized
    if contains(string(data{3}), '(r)')
        disp('imaged right side');
        touchtimes = data{5};

        touch_other_side = data{1};

    else
        disp('imaged left side');
        touchtimes = data{1};

        touch_other_side = data{5};

    end
else
    touchtimes = data{1};

    touch_other_side = data{5};

end

fluo = data{2};
outputfig = (data{3});
%check if touchtimes is empty
if isnan(touchtimes)
    touchstartframes = 0;
    eventsmat = 0';
    eventpeaks = 0;
    eventpeaks_mean = 0';
    eventpeaks_SEM = 0;
    mean_event = 0;
    SEM_event = 0;
    x_events = 0;
else

    touchtimes_shifted = circshift(touchtimes, [0, 1]);
    touchtimes_shifted(1) = 0;
    %subtract the shifted matrix from the original one (corresponds to
    %substracting the previous element from each element
    intervals = touchtimes - touchtimes_shifted;
    %find intervals of more than intervaltime between the touches (output type is
    %logical)
    starts = intervals >= intervaltime;
    %find starttimes of the touchevents
    starttimes = starts .* touchtimes;
    %This contains zeros for all spaces in the matrix that are not starts of touch events

    endtime_intervals = ((numframes - 1) / framerate) - touchtimes;

    %find out if event starts at least 'eventtime' before end of recording (output type is
    %logical)
    ends_on_time = endtime_intervals >= eventtime + basetime + (1 / framerate);
    %find starttimes of the touchevents
    starttimes = ends_on_time .* starttimes;
    %This contains zeros for all spaces in the matrix that do not end on time

    %check if the excludedoubles option was set to true -
    %this option excludes touches that occur on both sides at the same time

    if excludedoubles
        tfarray = arrayfun(@(time) (~doubletouch(time, intervaltime, eventtime, touch_other_side)), starttimes);
        starttimes = tfarray .* starttimes;
        %This contains zeros for all spaces in the matrix that overlap with a touch from the contralateral side
    end
    touchstarts = rmmissing(nonzeros(starttimes)); %reduce matrix to contain only starts
    %calculate the frame number from the time of the touchstarts
    touchstartframes = round(touchstarts*framerate);

    %calculate the timepoints
    x = 1:numframes;
    x = x / framerate;
    %changed to make frame one start at time 1/framerate instead of time 0 due to time required for laser scanning


    %this defines events and saves them to a cell array called events
    %the events are defined as the fluorescence trace starting at basetime
    %before touchstart and ending at touchstart + eventtime
    events = arrayfun(@(touchstart) ...
        fluo(touchstart - (ceil(basetime * framerate)):touchstart + (floor(eventtime * framerate))), ...
        touchstartframes, 'UniformOutput', false);
    %convert cell array events to a matrix - necessary for subsequent
    %calculations
    %[eventsmat, event]=makemyevents(events);
    events = transpose(events);
    eventsmat = cell2mat(transpose(events));
    eventsmat = transpose(eventsmat);
    %average all events frame by frame (after aligning them to the start of the
    %touch event)
    events_peak_aligned = arrayfun(@(touchstart) align_peaks(fluo, basetime, eventtime, framerate, touchstart), touchstartframes, 'UniformOutput', false);
    %convert cell array events to a matrix - necessary for subsequent
    %calculations
    %[eventsmat, event]=makemyevents(events);
    events_peak_aligned = transpose(events_peak_aligned);
    eventsmat_peak_aligned = cell2mat(transpose(events_peak_aligned));
    eventsmat_peak_aligned = transpose(eventsmat_peak_aligned);


    eventpeaks = transpose(max(eventsmat((round(basetime * framerate)+1:size(eventsmat, 1)), :)));
    % baseline for each event before the touch
    if ~isempty(eventsmat)
        eventbases = transpose(mean(eventsmat((1:round(basetime * framerate)+1), :)));

        %calculate deltaF/F for that event

        eventpeaks_dff = (eventpeaks - eventbases) ./ eventbases;
    else
        eventpeaks_dff = 0;
    end
    if ~isempty(eventsmat)

        eventbases1 = mean(eventsmat((1:round(basetime * framerate)+1), :));
        %calculate dF/F using the baseline from the events in eventsmat
        eventsmat = (eventsmat - eventbases1) ./ eventbases1;


    else

    end
    if ~isempty(eventsmat_peak_aligned)

        eventbases1_peak_aligned = mean(eventsmat_peak_aligned((1:round((basetime-2) * framerate)+1), :));
        %since the basetime here was calculated back from the peak, the baseline is
        %measured only until 2s before the peak (therefore basetime -2)
        %calculate dF/F using the baseline from the events in eventsmat
        eventsmat_peak_aligned = (eventsmat_peak_aligned - eventbases1_peak_aligned) ./ eventbases1_peak_aligned;


    else
    end
    mean_event_peak_aligned = mean(eventsmat_peak_aligned, 2);
    %SEM for each point in the averaged event
    SEM_event_peak_aligned = std(eventsmat_peak_aligned, 0, 2) / sqrt(size(eventsmat_peak_aligned, 2));
    mean_event = mean(eventsmat, 2);
    %SEM for each point in the averaged event
    SEM_event = std(eventsmat, 0, 2) / sqrt(size(eventsmat, 2));
    %calculate single peak of each event during eventtime
    %first_touch_event=eventsmat(:,1);


    %calculate the mean of the peaks of single events

    eventpeaks_mean = mean(eventpeaks_dff);
    eventpeaks_SEM = std(eventpeaks_dff, 0, 1) / sqrt(size(eventpeaks_dff, 1));

    %make the x (timepoints) for the events - times are relative to the onset
    %of the touch

    x_events = transpose(x(1:length(mean_event))-basetime);


end
end


function [foundexp] = foundstringnames(expname, numberstring)
if contains(expname, numberstring)

    foundexp = expname;


else
    foundexp = [];
end


end

function [ffounds, index] = execFoundstringnames(exparray, numbarray)
ffounds = cellfun(@(exp) foundstringnames(exp, numbarray), exparray, 'UniformOutput', false);

index = find(~cellfun('isempty', ffounds));
ffounds = ffounds(~cellfun('isempty', ffounds));

end
function [foundinfiles, fffounds, iindex] = foundInWhich(resultsarray, numbarray, rresultfilenames)
[fffounds, iindex] = cellfun(@(resultsfiles) execFoundstringnames(resultsfiles, numbarray), resultsarray, 'UniformOutput', false);

for i = 1:length(resultsarray)
    if isempty(fffounds{i})
        foundinfiles{i} = {};
    else

        foundinfiles{i} = rresultfilenames{i};
    end
end
fffounds = fffounds(~cellfun('isempty', fffounds));
foundinfiles = foundinfiles(~cellfun('isempty', foundinfiles));
iindex = iindex(~cellfun('isempty', iindex));


end
function[singleresult] = resultfinder(nameoffile, indexoffile)

expresults = table2array(readtable(char(nameoffile), 'Sheet', 'Sheet1', 'ReadVariableNames', 0));
singleresult = expresults(:, indexoffile);

end

%the function to create full touchtimes tables from reduced format
function[outputtimes] = expand_reduced_touchtimes(testtimes)
outputtimes = [];

for i = 1:2:length(testtimes) - 1


    for j = 0:round(testtimes(i + 1)-testtimes(i))
        outputtimes = [outputtimes; (testtimes(i) + j)];
    end

end
end

%checking if both sides were touching at the same time
function tf = doubletouch(touchtime, interval, dur, touchtimes_other_side)
tf = any((touchtime-interval) < touchtimes_other_side & touchtimes_other_side < (touchtime + dur));
end

%function for checking if data are from the same animal
function average_event = average_within_fly(foundfilenamearr, foundinarr, eventsmatarr, filename, foundinfilename)
flynumb = regexp(filename{1}, 'fly\d+(\(|\_)', 'match');
%expecting the filename to contain the string 'fly' followed by the fly number
sames = cellfun(@(foundfilename, foundin1) ...
    (contains(foundfilename{1}{1}, flynumb{1}) && (string(foundin1{1}) == string(foundinfilename))), ...
    foundfilenamearr, foundinarr);
%checking if both the flynumber and the resultfilename in which the
%experiment was found is the same
total_eventsmat = eventsmatarr(sames);
eventsmat_new = horzcat(total_eventsmat{:});
average_event = mean(eventsmat_new, 2);
end
function event = align_peaks(fluo, basetime, eventtime, framerate, touchstart)
[~, peakindex] = max(fluo(touchstart:touchstart + (floor(eventtime * framerate))));
event = fluo(peakindex+touchstart-1-(ceil((basetime) * framerate)):peakindex+touchstart-1+(floor((eventtime) * framerate)));
end
