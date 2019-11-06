function [dff,virgindff, virginf,filenames]=genitalia_touch(foldername,varargin)

arguments=varargin;
 options = struct('framerate',5.92,'numberframes',600,'baseline_start',2,'baseline_end',11,'outputdir','../Results');
%call the options_resolver function to check optional key-value pair
%arguments
[options,~]=options_resolver(options,arguments,'plot_with_touches');
%setting the values for optional arguments
framerate = options.framerate;
numberframes = options.numberframes;
baseline_start = options.baseline_start;
baseline_end = options.baseline_end;
outputdirv=options.outputdir;


%% 1. Set constants, variables and local functions

extracting = @mean; % taking the mean of each frame
%framerate = 5.92; % frame rate in Hz

%numberframes=600;
duration_acquisition = numberframes/framerate; 
%baseline_start = 2;
%baseline_end = 11;
startdir=pwd;

%foldername='2019_10_24';%the name of the imaging folder
subfoldername='ROI';%must be a folder within the imaging folder
stackdir = fullfile(foldername,subfoldername);


outputfilev=strcat(outputdirv,'_touch_needle.xlsx');
outputimgv=strcat(outputdirv,'_touch_needle.eps');

ee = 1;
ii = 1;
virgin = 0;%used here for touch needle




 
cd (startdir)

cd(stackdir)
files{ii}{ee} = dir('*.tif');
files{ii}{ee} = {files{ii}{ee}.name};
f = zeros(numberframes,(length(files{ii}{ee})));%make f array to safe fluorescence in number of frames is 600
df = zeros(numberframes,(length(files{ii}{ee})));%make the df array
dff = zeros(numberframes,(length(files{ii}{ee})));%make dff array  
filenames = cell((length(files{ii}{ee})),1);
filenames(:) = {''};

        % loop through images
        for gg = 1:length(files{ii}{ee})
            
            % go back into the stack directory
            cd(startdir);
            cd(stackdir);
            filename = files{ii}{ee}{gg};
            
           % end
            filenames(gg,1) = cellstr(filename);
            stackfilename = fullfile(stackdir,[filename]);
            tiffInfo = imfinfo(stackfilename);
            
            % read TIFF sequence
            no_frame = numel(tiffInfo);    %# Get the number of images in the file (numel is number elements in array)
            Movie{ii}{ee}{gg} = cell(no_frame,1);     
            %f = zeros(no_frame,(length(files{ii}{ee})));%make f array to safe fluorescence in
            
            for iFrame = 1:no_frame
                
                Movie{ii}{ee}{gg}{iFrame} = double(imread(stackfilename,'Index',iFrame,'Info',tiffInfo));
                %imshow(Movie{ii}{ee}{gg}{iFrame}); %display the image - for debugging only
                %calculating f
                f(iFrame,gg) = extracting(extracting(Movie{ii}{ee}{gg}{iFrame}));%calculate mean f for each frame
            end    
                %calculating baseline
                f0=mean(f(baseline_start:baseline_end,gg)); %calculate baseline between baseline_start and baseline_end
               
                
            for iFrame = 1:no_frame
                    %calculating df
                    df(iFrame,gg)=f(iFrame,gg)- f0;
                    
                    %calculating dff
                    dff(iFrame,gg)=df(iFrame,gg)/f0;
            end
            %plot(dff{ii}{ee}{gg});% for debugging
            
                      
        end
        virgins = strfind(filenames,'touch');
       
        nonvirgin = cellfun('isempty',virgins);
       
       
        for v = 1:length(filenames)
            if nonvirgin(v) == 0
               
                virgin =virgin+1;
                virgindff(:,virgin) =   dff(:,v);
                virginf(:,virgin) =   f(:,v);
                virginname(virgin)=filenames(v);
               
           
               
            end
        end
        
       
        if exist('virginf') == 1
        Tv=table(virginf);
        
        virginlegend=cellfun(@(name) regexp(name,'(\d\d\d)','match'), virginname, 'UniformOutput', true);
       
        
        Tvnames=table(virginname);
        cd(startdir);
        cd(outputdirv);
        writetable(Tv,outputfilev,'Sheet',1,'WriteVariableNames',false);
        writetable(Tvnames,outputfilev,'Sheet',2,'WriteVariableNames',false);
        virfig=figure('Name',outputimgv);
         
        plot(virgindff);
        legend(virginlegend,'Location','southeast');
        saveas(virfig,outputimgv,'epsc');
        
        end
        
        cd(startdir);



