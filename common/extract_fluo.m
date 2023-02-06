%extract the mean fluorescence for each frame of the tiffstack
function fluo = extract_fluo(tiffile, parallelize)
switch nargin
    case  1
        parallelize = false;
end
filename = tiffile;
if endsWith(filename, ".csv")
    fluo = load_fluo(filename);
else
tiffInfo = imfinfo(filename);

% Get the number of images in the file (numel is number elements in array)
no_frame = numel(tiffInfo);
fluo = zeros(1,no_frame);
% create empty cell array to preallocate memory;
if parallelize
    try
parfor iFrame = 1:no_frame
    %safe image date in the movie cell array
    Movie = double(imread(filename, ...%'Info', tiffInfo,...
        'Index', iFrame));
    %calculating f
    fluo(iFrame) = mean(Movie, 'all');
    fclose('all');
    %requires MATLAB 2018b or later!!!
end
    catch ME
        errorMessage = ME.message;
        disp(errorMessage);
        parallelize = false;
        
    end

else
    for iFrame = 1:no_frame
    %safe image date in the movie cell array
    Movie = double(imread(filename, ...%'Info', tiffInfo,...
        'Index', iFrame));
    %calculating f
    fluo(iFrame) = mean(Movie, 'all');
    fclose('all');
    %requires MATLAB 2018b or later!!!
    end
end
end