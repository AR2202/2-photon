# Short User Guide

## fly mating video analysis scripts

This is a collection of python scripts for the analysis of tracked fly mating videos.
The tracking is done using Deep Lab Cut. The Deep Lab Cut model was trained to label
points on the flies' head, abdomen and shoulders. These scripts are for calculating
the mating angle and tilting index. Furthermore, a machine learning model is trained
on these features to recognize normal vs. abnormal mating positions

### Requirements

* python 3
* the following python libraries:
* numpy
* scipy
* scikit-learn
* matplotlib
* pandas
* joblib
* pytest (for tests only)

### Usage

All of the descriptions below assume you have trained a Deep Lab Cut model to recognize the head, abdomen of both flies and shoulders of the male flies and applied that model to your videos. The outpul csv file of the model is the input data to these scripts.

#### calculating the mating angle and tilting index

To calculate the mating angle for each row of your csv file, use the function unfiltered_outputs() from the mating_angles_model2 module:

`mating_angles,wing_dist_male,abd_dist,head_dist=unfiltered_outputs(path_to_csv)`

mating_angles will be an array of your mating angles. This function also outputs wing distance in the male, distance of male to female abdomen, and distance of male to female head.

Alternatively, you can filter your data to only include those frames that exceed a minimum likelihood (the P argument) of the labelling that was done by Deep Lab Cut. To use filtering, use the filtered_outputs() function:

`mating_angles,wing_dist_male,abd_dist,head_dist=filtered_outputs(path_to_csv,P)`

To calculate the tilting index, use the function tilting_index from the mating_angles_model2 module:

`tilting_ind=tilting_index(wing_distance_male,copulationstartframe)`

tilting_ind will be an array of your tilting indices. The input arguments are the male wing distance, which can be obtained from the function unfiltered_outputs or filtered_outputs (see above) and the copulationstartframe= the start of your flies' copulation.

#### Using a script to calculate the median mating angles and tilting indices in a video

The sample script  model2_mating_angles can be used to calculate median mating angles and tilting indices. The paths are examples and have to be changed to the actual paths to the data. At the top of the file, change the line:
`sys.path.append("path")`
to the path of the mating_angles_model2.py file

Additional lines might need to be commented out if you don't have labelled data. You can also change some lines to print, plot or save the mating_angles and tilting_indices.

#### Removing frames close to the wall

The filtered_outputs() and unfiltered_outputs() functions in the mating_angles_model2.py module take the optional keyword arguments removeWall and minWallDist. Defaults are removeWall=False and minWallDist=3. removeWall specifies whether frames where flies are on the side wall should be removed. minWallDist is the minimum distance to the wall (in pixels) that flies should have if frames are to be kept.

#### Training a machine learning model to classify frames into 'normal' or 'abnormal' mating positions

#### Creating training data

Label some frames in your videos as in the example_labels.csv file. The first row should contain column headers. The columns should be:

* column 1: copulation start frame for that video (one row only)
* column 2: normal position frame numbers, pairs of consecutive rows will be interpreted as start and end frame of a normal period
* column 3: abnormal position frame numbers, pairs of consecutive rows will be interpreted as start and end frame of a normal period

#### Training the model

Use the function learning_pipeline() from the mating_angles_learn_model2.py module:

`models=learning_pipeline(list_of_paths_to_training,list_of_paths_to_labels,featurelist=features)`

featurelist ist an optional argument, you can specify the features you want to use for training. The default is:

`features=["angles_b_scaled","head_dist_scaled","abd_dist_scaled","tilting_index_scaled"]`

Select subsets of those features as you wish.

#### Training the model from a script

The script model2_mating_position.py gives an example of how to train the model. The paths have to be changed.

#### Loading a pretrained model

Use the load_pretrained() function from the mating_angles_learn_model2.py module:
`models=load_pretrained(path_to_model)`

#### Evaluating a pretrained model on new data

* create new labelled test data as outlined above
* Use the evaluate_pretrained() function from the mating_angles_learn_model2.py module: 

`scores=evalulate_pretrained(list_of_paths_to_test_csv,list_of_paths_to_test,featurelist=features)`

#### Applying the pretrained model to new data

`models=load_pretrained(path_to_model)`

`data=prepare_training_data(path_to_data_csv,copstartframe=copulationstartframe,featurelist=features)`

`predictions_data1,fraction1=apply_pretrained(models,data,startframe=copulationstartframe)`

The keyword arguments are optional.

#### Using a script to evaluate and apply an existing model

The script model2_test_apply.py gives an example of how to train the model. The paths have to be changed.

## 2-photon Calcium imaging analysis scripts

This is a collection of MATLAB scripts for calcium imaging data analysis.

### Requirements

* MATLAB R2016a or later. MATLAB R2017a or later recommended.
* All of the scripts in this package need to be in the MATLAB path
* Boundedline package available from:

https://www.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m


### Usage

#### Image stabilization, background subtraction and ROI selection

1. Run image stabilizer Fiji scripts in the  preprocessing_Fiji folder. Select your script:

* image_stabilize_wholedir.ijm for stabilization only
* image_stabilize_wholedir_deinterleave.ijm for 2 channel experiment
* image_stabilize_wholedir_deinterleave3channel.ijm for 3 channel experiment

2. Run the background subtraction and ROI selection script:

* Run bckg-sub_makeROI_wholedir_with_exclude.ijm for single ROI per file
* Run bckg-sub_multiROI_wholedir_with_exclud.ijm for multiple ROIs per file

#### Analysing functional connectivity calcium imaging experiments

1. Run the Fiji scripts for image stabilization, background subtraction and ROI selection (see above
)
2. Run the MATLAB script frequencyplot.m in the LED-pulselength folder

Navigate to the folder that contains your imaging folder. The script expects the directory structure to be either of the following:

* an imaging folder containing a subdirectory named 'subfoldername' (default: 'ROI') (along with a variable number of other folders, that will not be analysed) or:
* an imaging folder containing multiple subdirectories, each of which contains a subdirectory named 'subfoldername'(default: 'ROI')
* The filename should follow these conventions: \*gender\*neuronpart\*pulsedur\*fHz\*pulselength\*.tif

where gender, neuronpart, pulsedur,f,pulselength correspond to those values passed as arguments to the function frequencyplot() (or their defaults).

Run the following command from the MATLAB command window:

`frequencyplot(foldername,varargin)`

Required argument:

foldername: the name of the imaging folder

Optional key-value-pair arguments:

'framerate': numeric (in Hz), default: 5.92

'baseline_start': numeric (in frames), default: 2

'baseline_end': numeric (in frames), default: 11

'frequencies': 1-D array, default: [4,10,20,40]

'pulselengths': 1-D array, default: [8,12,20]

'pulsetimes': 1-D-array, default: [20,40,60,80]

'genders': cell array, default: {'_female';'_male'}

'neuronparts': cell array, default: {'medial';'lateral'}

'pulsedur': numeric (in s), default 5

'resultsdir': name of folder where results should go, default 'Results'

'multiroi': multiple ROIs per file, default false

'numrois': number of ROIs per file ,default: 1

'pulsetimesfromfile': read stimulation times from a file, default: false

'pulsetimesfile': name of the file containing the stimulus times, only relevant if pulsetimesfromfile is set to true; default: 'stimtimes.mat'

'subfoldername': name of the imaging subfolder (a subdirectory of 'foldername' or of each of its subdirectories), default: 'ROI'

The script will output several .mat files containing the data per experiment type as well as .eps files. It will also create a plot of ∆F/F vs frequency.

#### Analysing touch experiments

1. Run the Fiji scripts for image stabilization, background subtraction and ROI selection (see above
)
2. a. Run the MATLAB script genitalia_touch.m in the touch folder for each experiment folder you want to analyse:

Navigate to the folder that contains your imaging folder. The script expects the directory structure to adhere to the following rules:

* the argument given to the function is an imaging folder containing a subdirectory named 'ROI' or 'ROIS' (if 'multiroi' is set to true)
* a Results folder called 'Results' where the Results should be saved is in a directory upstream of the directory that the script is run from. If the directory structure does not conform to these conventions, additional arguments have to be given to specify where the folders are located (see below)

Run the following command from the MATLAB command window (or from a script):

`genitalia_touch(foldername,varargin)`

Required argument:

foldername: the name of the imaging folder

Optional key-value-pair arguments:

'framerate': numeric (in Hz), default: 5.92

'baseline_start': numeric (in frames), default: 2

'baseline_end': numeric (in frames), default: 11

'outputdir': directory where the .xlsx table and plot of results should be saved

'multiroi': multiple ROIs per file, default false

The script will output an .xlsx files containing the data per experiment type as well as .eps files. 

2. b. Instead of running the script for each folder individually as outlined in 2. a.), a script can be run from the top directory to analyse all experiments at once with the run_genitalia_touch() function. If no arguments are given, a subfolder  named 'imaging_preprocessed' is expected to exist in the current diretory, which contains the imaging experiment folders. A different name for this folder can be provided by the optional argument 'foldername'.

Run the following command from the MATLAB command window (or from a script):

`run_genitalia_touch(varargin)`

Required argument: None

Optional key-value-pair arguments:

'foldername': the name of the folder containing the imaging folders

'framerate': numeric (in Hz), default: 5.92

'baseline_start': numeric (in frames), default: 2

'baseline_end': numeric (in frames), default: 11

'outputdir': directory where the .xlsx table and plot of results should be saved

'multiroi': multiple ROIs per file, default false

The script will output an .xlsx files containing the data per experiment type as well as .eps files. 


3. Make an .xlsx table containing times of the touches, either by watching the behavioural video and manually marking frames or by automated video analysis. Save a separate .xlsx table for each imaging experiment. The name of the .xlsx file should be 'touchtimes_[imaging_foldername]_[experiment_number]' where imaging_foldername == the name of the folder the respective experiment can be found in and experiment_number is the 3-digit number of the imaging experiment.

The touchtimes can either be specified framewise, i.e. each frame of the video that contains a touch is specified separately, or only the start and the end of each touch are given. The latter is referred to as the 'reduced touchtimes format' in the following description.

4. Plot each experiment with touches (optional)

Run the following command from the MATLAB command window (or from a script):

`plot_with_touches(varargin)`

Required argument: None

Optional key-value-pair arguments:

'framerate': numeric (in Hz), default: 5.92

'touchdir': path to the directory containing the .xlsx tables of touchtimes, default: 'touchtimes'

'resultsdir': path to the directory containing the .xlsx tables of the imaging data created by 'genitala_touch', default: 'Results'

'outputdirmean': directory where results should be saved

'reduced': whether reduced touchtimes format was used, see above

If reduced is set to true, the script assumes the touchtimes files are in 'reduced touchtimes format' (see above). If it is set to false, it assumes all touchtimes are given separately. If the 'reduced' parameter is not explicitly specified, the script assumes that the touchtimes files adhere to the following rule: if the name of the folder containing the files (the 'touchdir' parameter) contains the string 'reduced', 'reduced touchtimes format' was used. Otherwise, all touchtimes for all frames containing touches are given.

Examples:

`plot_with_touches('touchdir','touchtimes_reduced')`

or

`plot_with_touches('reduced',true)`

or

`plot_with_touches('touchdir','my_touchtimes','reduced',true)`

will use the reduced touchtimes format, while

`plot_with_touches('touchdir','touchtimes_reduced','reduced',false)`

or

`plot_with_touches('touchdir','my_touchtimes','reduced',false)`

will not.

5. Align imaging results to touches 

Run the following command from the MATLAB command window (or from a script):

`align_touches(varargin)`

Required argument: None

Optional key-value-pair arguments:

'framerate': numeric (in Hz), default: 5.92

'numframes': number of imaging frames, default: 600

'touchdir': path to the directory containing the .xlsx tables of touchtimes, default: 'touchtimes'

'resultsdir': path to the directory containing the .xlsx tables of the imaging data created by 'genitala_touch', default: 'Results'

'outputdirmean': directory where results should be saved

'outputdir_singles': directory where results for single experiments should be saved (depricated)

'basetime': length of baseline in s

'eventtime': length of an event in s

'intervaltime': min time between touches in s

'excludedoubles: whether touches on both sides in a short timeperiod should be excluded. Default: false

'filterstring' : a string by which exps should be filtered; this can be a specific part of the neuron imaged from or a treatment type

'reduced': whether reduced touchtimes format was used, see above