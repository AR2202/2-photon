function fluo=extract_fluo(tiffile)
            startdir=pwd;
            filename = tiffile;
            tiffInfo = imfinfo(filename);
            
          % Get the number of images in the file (numel is number elements in array)
            no_frame = numel(tiffInfo);    
          % create empty cell array to preallocate memory; 
            Movie = cell(no_frame);  
            for iFrame = 1:no_frame
                %safe image date in the movie cell array
                Movie{iFrame} = double(imread(filename,'Index',iFrame,'Info',tiffInfo));
                 %calculating f
                fluo(iFrame) = mean(Movie{iFrame},'all');%requires MATLAB 2018b or later!!!
            end   