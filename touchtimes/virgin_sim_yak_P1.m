
clear all; 

%% 1. Set constants, variables and local functions

extracting = @mean; % taking the mean of each frame
framerate = 5.92; % frame rate in Hz

numberframes=500;
duration_acquisition = numberframes/framerate; 
baseline_start = 2;
baseline_end = 11;
startdir=pwd;
pathname='/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/P1_female_touch/imaging_preprocessed';
%pathname has to be the path to the folder were files to be processed are
%located
foldername='2017_02_14';%the name of the imaging folder
subfoldername='ROI';%must be a folder within the imaging folder
stackdir = fullfile(pathname,foldername,subfoldername);
outputdirv=('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/P1_female_touch/Results_P1');
outputdirsim=('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/P1_female_touch/Results_P1');
outputdiryak=('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/P1_female_touch/Results_P1');
outputfilev=strcat(foldername,'_virgin.xlsx');
outputimgv=strcat(foldername,'_virgin.eps');
outputfiles=strcat(foldername,'_simulans.xlsx');
outputimgs=strcat(foldername,'_simulans.eps');
outputfiley=strcat(foldername,'_yakuba.xlsx');
outputimgy=strcat(foldername,'_yakuba.eps');
outputfilem=strcat(foldername,'_male.xlsx');
outputimgm=strcat(foldername,'_male.eps');
ee = 1;
ii = 1;
virgin = 0;
sim = 0;
yak =0;
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
        sims = strfind(filenames, 'sim');
        yaks = strfind(filenames, 'yak');
       males = strfind(filenames, 'male');
       
        nonsim = cellfun('isempty',sims);
        nonvirgin = cellfun('isempty',virgins);
        nonyak = cellfun('isempty',yaks);
        nonmale = cellfun('isempty',males);
       
        for v = 1:length(filenames)
            if nonvirgin(v) == 0
               
                virgin =virgin+1;
                virgindff(:,virgin) =   dff(:,v);
                virginname(virgin)=filenames(v);
               
            elseif nonsim(v) == 0
                sim = sim+1;
                simdff(:,sim) =   dff(:,v);
                simname(sim)=filenames(v);
               
            elseif nonyak(v) == 0
                yak = yak+1;
                yakdff(:,yak) =   dff(:,v);
                yakname(yak)=filenames(v);
                
             elseif nonmale(v) == 0
                male = male+1;
                maledff(:,male) =   dff(:,v);
                malename(male)=filenames(v);
               
            end
        end
        
       
        if exist('virgindff') == 1
        Tv=table(virgindff);
       
        Tvnames=table(virginname);
        cd(outputdirv);
        writetable(Tv,outputfilev,'Sheet',1,'WriteVariableNames',false);
        writetable(Tvnames,outputfilev,'Sheet',2,'WriteVariableNames',false);
        virfig=figure();
        plot(virgindff);
        %legend(virginname,'Location','southeast');
        saveas(virfig,outputimgv,'epsc');
        
        end
        if exist('simdff')==1 
        Ts=table(simdff);
         Tsnames=table(simname);
          cd(outputdirsim); 
        writetable(Ts,outputfiles,'Sheet',1,'WriteVariableNames',false);
        writetable(Tsnames,outputfiles,'Sheet',2,'WriteVariableNames',false);
        simfig=figure();
        plot(simdff);
       % legend(simname,'Location','southeast');
        saveas(simfig,outputimgs,'epsc');
        end
       
        if exist('yakdff')==1
        Ty=table(yakdff);
         Tynames=table(yakname);
           
         cd(outputdiryak);
         writetable(Ty,outputfiley,'Sheet',1,'WriteVariableNames',false);
        writetable(Tynames,outputfiley,'Sheet',2,'WriteVariableNames',false);
        yakfig=figure();
        plot(yakdff);
        %legend(yakname,'Location','southeast');
        saveas(yakfig,outputimgy,'epsc');
        end
        
        
        if exist('maledff')==1
        Tm=table(maledff);
         Tmnames=table(malename);
           
         cd(outputdiryak);
         writetable(Tm,outputfilem,'Sheet',1,'WriteVariableNames',false);
        writetable(Tmnames,outputfilem,'Sheet',2,'WriteVariableNames',false);
        malefig=figure();
        plot(maledff);
        %legend(yakname,'Location','southeast');
        saveas(malefig,outputimgm,'epsc');
        end
        cd(startdir);



