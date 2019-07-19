
clear all; 

%% 1. Set constants, variables and local functions

extracting = @mean; % taking the mean of each frame
framerate = 5.92; % frame rate in Hz

numberframes=600;
duration_acquisition = numberframes/framerate; 
baseline_start = 2;
baseline_end = 11;
startdir=pwd;
pathname='/Volumes/LaCie/Projects/aDN/imaging/aDN_touch/imaging_preprocessed';
%pathname has to be the path to the folder were files to be processed are
%located
foldername='2019_07_09';%the name of the imaging folder
subfoldername='ROI';%must be a folder within the imaging folder
stackdir = fullfile(pathname,foldername,subfoldername);
outputdirv=('/Volumes/LaCie/Projects/aDN/imaging/aDN_touch/Results');
outputdirsim=('/Volumes/LaCie/Projects/aDN/imaging/aDN_touch/Results');
outputdiryak=('/Volumes/LaCie/Projects/aDN/imaging/aDN_touch/Results');
outputfilev=strcat(foldername,'_virgin.xlsx');
outputimgv=strcat(foldername,'_virgin.eps');
outputfiles=strcat(foldername,'_oenocytelessM.xlsx');
outputimgs=strcat(foldername,'_oenocytelessM.eps');
outputfiley=strcat(foldername,'_ball.xlsx');
outputimgy=strcat(foldername,'_ball.eps');
outputfilem=strcat(foldername,'_male.xlsx');
outputimgm=strcat(foldername,'_male.eps');
ee = 1;
ii = 1;
virgin = 0;
sim = 0; %used here for oe- female
yak =0; % used here for ball touch
male=0;



 


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
        virgins = strfind(filenames,'virgin');
        sims = strfind(filenames, 'oenegm');
        yaks = strfind(filenames, 'ball');
       males = strfind(filenames, 'touch_male');
       
        nonsim = cellfun('isempty',sims);
        nonvirgin = cellfun('isempty',virgins);
        nonyak = cellfun('isempty',yaks);
        nonmale = cellfun('isempty',males);
       
        for v = 1:length(filenames)
            if nonvirgin(v) == 0
               
                virgin =virgin+1;
                virgindff(:,virgin) =   dff(:,v);
                virginf(:,virgin) =   f(:,v);
                virginname(virgin)=filenames(v);
               
            elseif nonsim(v) == 0
                sim = sim+1;
                simdff(:,sim) =   dff(:,v);
                simf(:,sim) =   f(:,v);
                simname(sim)=filenames(v);
               
            elseif nonyak(v) == 0
                yak = yak+1;
                yakdff(:,yak) =   dff(:,v);
                yakf(:,yak) =   f(:,v);
                yakname(yak)=filenames(v);
                
             elseif nonmale(v) == 0
                male = male+1;
                maledff(:,male) =   dff(:,v);
                malef(:,male) =   f(:,v);
                malename(male)=filenames(v);
               
            end
        end
        
       
        if exist('virginf') == 1
        Tv=table(virginf);
        
        virginlegend=cellfun(@(name) regexp(name,'(\d\d\d)','match'), virginname, 'UniformOutput', true);
       
        
        Tvnames=table(virginname);
        cd(outputdirv);
        writetable(Tv,outputfilev,'Sheet',1,'WriteVariableNames',false);
        writetable(Tvnames,outputfilev,'Sheet',2,'WriteVariableNames',false);
        virfig=figure('Name',outputimgv);
         
        plot(virgindff);
        legend(virginlegend,'Location','southeast');
        saveas(virfig,outputimgv,'epsc');
        
        end
        if exist('simf')==1 
        Ts=table(simf);
         Tsnames=table(simname);
        simlegend=cellfun(@(name) regexp(name,'(\d\d\d)','match'), simname, 'UniformOutput', true);
       
          cd(outputdirsim); 
        writetable(Ts,outputfiles,'Sheet',1,'WriteVariableNames',false);
        writetable(Tsnames,outputfiles,'Sheet',2,'WriteVariableNames',false);
        simfig=figure('Name',outputimgs);
        plot(simdff);
        legend(simlegend,'Location','southeast');
        saveas(simfig,outputimgs,'epsc');
        end
       
        if exist('yakf')==1
        Ty=table(yakf);
         Tynames=table(yakname);
            yaklegend=cellfun(@(name) regexp(name,'(\d\d\d)','match'), yakname, 'UniformOutput', true);
       
         cd(outputdiryak);
         writetable(Ty,outputfiley,'Sheet',1,'WriteVariableNames',false);
        writetable(Tynames,outputfiley,'Sheet',2,'WriteVariableNames',false);
        yakfig=figure('Name',outputimgy);
        plot(yakdff);
        legend(yaklegend,'Location','southeast');
        saveas(yakfig,outputimgy,'epsc');
        end
        
        
        if exist('malef')==1
        Tm=table(malef);
         Tmnames=table(malename);
           malelegend=cellfun(@(name) regexp(name,'(\d\d\d)','match'), malename, 'UniformOutput', true);
       
         cd(outputdiryak);
         writetable(Tm,outputfilem,'Sheet',1,'WriteVariableNames',false);
        writetable(Tmnames,outputfilem,'Sheet',2,'WriteVariableNames',false);
        malefig=figure('Name',outputimgm);
        plot(maledff);
        legend(malelegend,'Location','southeast');
        saveas(malefig,outputimgm,'epsc');
        end
        cd(startdir);



