%Annika Rings, 2021
%LED_STIM
function LED_stim(foldername, varargin)


%------------------------------------------------------------------------

%% optional key-value pair arguments and their defaults
%------------------------------------------------------------------------
options = struct('framerate', 5.92, ...
    'baseline', 6, ...
    'after_pulse', 6, ...
    'genders', {{'_male'; '_female'}}, ...
    'protocols', {{'40Hz'}}, ...
    'neuronparts', {{'medial'; 'lateral'}}, ...
    'resultsdir', 'Results', ...
    'multiroi', false, ...
    'numrois', 1, ...
    'roinames', {{}}, ...
    'inhibitor_conc', [0], ...
    'inhibitor_unit', 'uM', ...
    'inhibitor_names', {{'PTX'}}, ...
    'subfoldername', 'ROI', 'stimdir', 'stim', ...
    'protocolname', '_4pulse_5s', ...
    'firstpulse', false, ...
    'eventdur', 180, ...
    'parallelize', true, ... % requires parallel computing toolbox
    'pulseframe', 61, ...
    'use_fluo', false, ...
    'stimintensity', 1, ...
    'stabilized', true);

arguments = varargin;

%------------------------------------------------------------------------

%% setting optional key-value pair arguments
%-------------------------------------------------------------------------

%call the options_resolver function to check optional key-value pair
%arguments
[options, ~] = options_resolver(options, arguments, 'LED_Stim');

%this block gets all the values from the optional function arguments
%for all arguments that were not specified, the default is used

analyse_fluo_stim(foldername, ...
    'framerate', options.framerate, ...
    'baseline', options.baseline, ...
    'after_pulse', options.after_pulse, ...
    'protocols', options.protocols, ...
    'genders', options.genders, ...
    'neuronparts', options.neuronparts, ...
    'resultsdir', options.resultsdir, ...
    'multiroi', options.multiroi, ...
    'numrois', options.numrois, ...
    'roinames', options.roinames, ...
    'inhibitor_conc', options.inhibitor_conc, ...
    'inhibitor_unit', options.inhibitor_unit, ...
    'inhibitor_names', options.inhibitor_names, ...
    'subfoldername', options.subfoldername, ...
    'stimdir', options.stimdir, ...
    'protocolname', options.protocolname, ...
    'firstpulse', options.firstpulse, ...
    'pulseframe', options.pulseframe, ...
    'eventdur', options.eventdur, ...
    'parallelize', options.parallelize, ... % requires parallel computing toolbox
    'use_fluo', options.use_fluo, ...
    'stabilized', options.stabilized, ...
    'stimtype', 'LED', ...
    'stimintensity', options.stimintensity);
