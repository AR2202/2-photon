
clear all; 

%% 1. Set constants, variables and local functions

extracting = @mean; % taking the mean of each frame
framerate = 5.92; % frame rate in Hz

numberframes=600;
duration_acquisition = numberframes/framerate; 
baseline_start = 6;%updated Feb 2018
baseline_end = 30;%updated Feb 2018
startdir=pwd;
pathname='/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/LC10-lexA_lexAop-CSChrimson_aDN_GCaMP6f/imaging_preprocessed';
%pathname has to be the path to the folder were files to be processed are
%located
foldername='2018_04_06';%the name of the imaging folder
subfoldername='ROI';%must be a folder within the imaging folder
stackdir = fullfile(pathname,foldername,subfoldername);
outputdirv=('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/LC10-lexA_lexAop-CSChrimson_aDN_GCaMP6f/Results');
outputfile1p5s=strcat(foldername,'_1p05s.xlsx');
outputimg1p5s=strcat(foldername,'_1p05s.eps');
outputfile2p5s=strcat(foldername,'_2p05s.xlsx');
outputimg2p5s=strcat(foldername,'_2p05s.eps');
outputfile4p5s=strcat(foldername,'_4p05s.xlsx');
outputimg4p5s=strcat(foldername,'_4p05s.eps');
outputfile1p20s=strcat(foldername,'_1p20s.xlsx');
outputimg1p20s=strcat(foldername,'_1p20s.eps');
outputfile2p20s=strcat(foldername,'_2p20s.xlsx');
outputimg2p20s=strcat(foldername,'_2p20s.eps');
outputfile4p1s=strcat(foldername,'_4p01s.xlsx');
outputimg4p1s=strcat(foldername,'_4p01s.eps');
outputfile4p2s=strcat(foldername,'_4p02s.xlsx');
outputimg4p2s=strcat(foldername,'_4p02s.eps');

ee = 1;
ii = 1;
n1p5s = 0;
n2p5s = 0;
n4p5s =0;
n1p20s =0;
n2p20s =0;
n4p1s =0;
n4p2s =0;

 n1p5so = 0;
 n1p5sms = 0;
 n1p5sl = 0;
 n1p5slc = 0;
 n1p5sfs =0;
 n1p5sdd = 0;
 n1p5sfl =0;
 n1p5sds =0;
 n1p5smd =0;
 n1p5sc =0;
 
 n2p5so = 0;
 n2p5sms = 0;
 n2p5sl = 0;
 n2p5slc = 0;
 n2p5sfs =0;
 n2p5sdd = 0;
 n2p5sfl =0;
 n2p5sds =0;
 n2p5smd =0;
 n2p5sc =0;
 
 n4p5so = 0;
 n4p5sms = 0;
 n4p5sl = 0;
 n4p5slc = 0;
 n4p5sfs =0;
 n4p5sdd = 0;
 n4p5sfl =0;
 n4p5sds =0;
 n4p5smd =0;
 n4p5sc =0;
 
 n1p20so = 0;
 n1p20sms = 0;
 n1p20sl = 0;
 n1p20slc = 0;
 n1p20sfs =0;
 n1p20sdd = 0;
 n1p20sfl =0;
 n1p20sds =0;
 n1p20smd =0;
 n1p20sc =0;
    
n2p20so = 0;
 n2p20sms = 0;
 n2p20sl = 0;
 n2p20slc = 0;
 n2p20sfs =0;
 n2p20sdd = 0;
 n2p20sfl =0;
 n2p20sds =0;
 n2p20smd =0;
 n2p20sc =0;
    
n4p1so = 0;
 n4p1sms = 0;
 n4p1sl = 0;
 n4p1slc = 0;
 n4p1sfs =0;
 n4p1sdd = 0;
 n4p1sfl =0;
 n4p1sds =0;
 n4p1smd =0;
 n4p1sc =0;
  
 n4p2so = 0;
 n4p2sms = 0;
 n4p2sl = 0;
 n4p2slc = 0;
 n4p2sfs =0;
 n4p2sdd = 0;
 n4p2sfl =0;
 n4p2sds =0;
 n4p2smd =0;
 n4p2sc =0;
  
  
  


pulsetimes1p5s=[40];
pulsetimes1p20s=[40];
pulsetimes2p5s=[30,60];
pulsetimes4p5s=[20,40,60,80];
pulsetimes2p20s=[20,60];
pulsetimes4p1s=[20,40,60,80];
pulsetimes4p2s=[20,40,60,80];







 


cd(stackdir)
files{ii}{ee} = dir('*.tif');
files{ii}{ee} = {files{ii}{ee}.name};
f = zeros(numberframes,(length(files{ii}{ee})));%make f array to safe fluorescence in number of frames is 600
df = zeros(numberframes,(length(files{ii}{ee})));%make the df array
dff4p5s = zeros(numberframes,(length(files{ii}{ee})));%make dff array  
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
          
            for iFrame = 1:no_frame
                
                Movie{ii}{ee}{gg}{iFrame} = double(imread(stackfilename,'Index',iFrame,'Info',tiffInfo));
              
                %calculating f
                f(iFrame,gg) = extracting(extracting(Movie{ii}{ee}{gg}{iFrame}));%calculate mean f for each frame
            end    
                %calculating baseline
                f0=mean(f(baseline_start:baseline_end,gg)); %calculate baseline between baseline_start and baseline_end
               % disp(f0); %print baseline value - for debugging only
                
            for iFrame = 1:no_frame
                    %calculating df
                    df(iFrame,gg)=f(iFrame,gg)- f0;
                    
                    %calculating dff
                    dff(iFrame,gg)=df(iFrame,gg)/f0;
            end
           
                      
        end
        %finding the pulse specifications in the file name - must be
        %spelled as indicated
        f1p5s = strfind(filenames,'1pulse_5s');
        f2p5s = strfind(filenames, '2pulse_5s');
        f4p5s = strfind(filenames, '4pulse_5s');
        f1p20s = strfind(filenames, '1pulse_20s');
        f2p20s = strfind(filenames, '2pulse_20s');
        f4p1s = strfind(filenames, '4pulse_1s');
        f4p2s = strfind(filenames, '4pulse_2s');
        
        
        non1p5s = cellfun('isempty',f1p5s);
        non2p5s = cellfun('isempty',f2p5s);
        non4p5s = cellfun('isempty',f4p5s);
        non1p20s = cellfun('isempty',f1p20s);
        non2p20s = cellfun('isempty',f2p20s);
        non4p1s = cellfun('isempty',f4p1s);
        non4p2s = cellfun('isempty',f4p2s);
        
        %finding recording location specifications in the file name
        foverview = strfind(filenames,'overview');%does not exist
        fmiddlesup = strfind(filenames,'medial_superficial');
        flateral = strfind(filenames,'lateral_mid');
        flatcell = strfind(filenames,'lateral_deep');
        ffrontalsup = strfind(filenames,'lateral_sup');
        fdorsaldeep = strfind(filenames,'dorsal_deep');%does not exist
        ffrontallat = strfind(filenames,'frontal_lateral');%does not exist
        fdorsalsup = strfind(filenames,'_cellbodies');
        fmiddledeep = strfind(filenames,'medial_deep');
        fconnect = strfind(filenames,'connection');%does not exist
        
        nonoverview = cellfun('isempty',foverview);
        nonmiddlesup = cellfun('isempty',fmiddlesup);
        nonlateral = cellfun('isempty',flateral);
        nonlatcell = cellfun('isempty',flatcell);
        nonfrontalsup = cellfun('isempty',ffrontalsup);
        nondorsaldeep = cellfun('isempty',fdorsaldeep);
        nonfrontallat = cellfun('isempty',ffrontallat);
        nondorsalsup = cellfun('isempty',fdorsalsup);
        nonmiddledeep = cellfun('isempty',fmiddledeep);
        nonconnect = cellfun('isempty',fconnect);
        
        for v = 1:length(filenames)
            if non1p5s(v) == 0 %if the file has a 1pulse_5s pulse protocol
               
                n1p5s =n1p5s+1;
                dff1p5s(:,n1p5s) =   dff(:,v); %make a new matrix to safe dff of all files with this pulse protocol
                name1p5s(n1p5s)=filenames(v);
                if nonoverview(v) == 0
                   n1p5so = n1p5so + 1;
                   dff1p5so(:,n1p5so) = dff(:,v);
                   name1p5so(n1p5so)=filenames(v);
                elseif nonmiddlesup(v) == 0
                   n1p5sms = n1p5sms + 1;
                   dff1p5sms(:,n1p5sms) = dff(:,v);
                   name1p5sms(n1p5sms)=filenames(v);
                elseif nonlateral(v) == 0
                   n1p5sl = n1p5sl + 1;
                   dff1p5sl(:,n1p5sl) = dff(:,v);
                   name1p5sl(n1p5sl)=filenames(v);
                 elseif nonlatcell(v) == 0
                   n1p5slc = n1p5slc + 1;
                   dff1p5slc(:,n1p5slc) = dff(:,v);
                   name1p5slc(n1p5slc)=filenames(v);
                 elseif nonfrontalsup(v) == 0
                   n1p5sfs = n1p5sfs + 1;
                   dff1p5sfs(:,n1p5sfs) = dff(:,v);
                   name1p5sfs(n1p5sfs)=filenames(v);
                 elseif nondorsaldeep(v) == 0
                   n1p5sdd = n1p5sdd + 1;
                   dff1p5sdd(:,n1p5sdd) = dff(:,v);
                   name1p5sdd(n1p5sdd)=filenames(v);
                 elseif nonfrontallat(v) == 0
                   n1p5sfl = n1p5sfl + 1;
                   dff1p5sfl(:,n1p5sfl) = dff(:,v);
                   name1p5sfl(n1p5sfl)=filenames(v);
                  elseif nondorsalsup(v) == 0
                   n1p5sds = n1p5sds + 1;
                   dff1p5sds(:,n1p5sds) = dff(:,v);
                   name1p5sds(n1p5sds)=filenames(v);
                  elseif nonmiddledeep(v) == 0
                   n1p5smd = n1p5smd + 1;
                   dff1p5smd(:,n1p5smd) = dff(:,v);
                   name1p5smd(n1p5smd)=filenames(v);
                  elseif nonconnect(v) == 0
                   n1p5sc = n1p5sc + 1;
                   dff1p5sc(:,n1p5sc) = dff(:,v);
                   name1p5sc(n1p5sc)=filenames(v);
                    
                  end   
               
            elseif non2p5s(v) == 0
                n2p5s = n2p5s+1;
                dff2p5s(:,n2p5s) =   dff(:,v);
                name2p5s(n2p5s)=filenames(v);
                if nonoverview(v) == 0
                   n2p5so = n2p5so + 1;
                   dff2p5so(:,n2p5so) = dff(:,v);
                   name2p5so(n2p5so)=filenames(v);
                elseif nonmiddlesup(v) == 0
                   n2p5sms = n2p5sms + 1;
                   dff2p5sms(:,n2p5sms) = dff(:,v);
                   name2p5sms(n2p5sms)=filenames(v);
                elseif nonlateral(v) == 0
                   n2p5sl = n2p5sl + 1;
                   dff2p5sl(:,n2p5sl) = dff(:,v);
                   name2p5sl(n2p5sl)=filenames(v);
                 elseif nonlatcell(v) == 0
                   n2p5slc = n2p5slc + 1;
                   dff2p5slc(:,n2p5slc) = dff(:,v);
                   name2p5slc(n2p5slc)=filenames(v);
                 elseif nonfrontalsup(v) == 0
                   n2p5sfs = n2p5sfs + 1;
                   dff2p5sfs(:,n2p5sfs) = dff(:,v);
                   name2p5sfs(n2p5sfs)=filenames(v);
                 elseif nondorsaldeep(v) == 0
                   n2p5sdd = n2p5sdd + 1;
                   dff2p5sdd(:,n2p5sdd) = dff(:,v);
                   name2p5sdd(n2p5sdd)=filenames(v);
                 elseif nonfrontallat(v) == 0
                   n2p5sfl = n2p5sfl + 1;
                   dff2p5sfl(:,n2p5sfl) = dff(:,v);
                   name2p5sfl(n2p5sfl)=filenames(v);
                  elseif nondorsalsup(v) == 0
                   n2p5sds = n2p5sds + 1;
                   dff2p5sds(:,n2p5sds) = dff(:,v);
                   name2p5sds(n2p5sds)=filenames(v);
                  elseif nonmiddledeep(v) == 0
                   n2p5smd = n2p5smd + 1;
                   dff2p5smd(:,n2p5smd) = dff(:,v);
                   name2p5smd(n2p5smd)=filenames(v);
                  elseif nonconnect(v) == 0
                   n2p5sc = n2p5sc + 1;
                   dff2p5sc(:,n2p5sc) = dff(:,v);
                   name2p5sc(n2p5sc)=filenames(v);
                    
                  end   
               
            elseif non4p5s(v) == 0
                n4p5s = n4p5s+1;
               dff4p5s(:,n4p5s) =   dff(:,v);
               name4p5s(n4p5s)=filenames(v);
               if nonoverview(v) == 0
                   n4p5so = n4p5so + 1;
                   dff4p5so(:,n4p5so) = dff(:,v);
                   name4p5so(n4p5so)=filenames(v);
                elseif nonmiddlesup(v) == 0
                   n4p5sms = n4p5sms + 1;
                   dff4p5sms(:,n4p5sms) = dff(:,v);
                   name4p5sms(n4p5sms)=filenames(v);
                elseif nonlateral(v) == 0
                   n4p5sl = n4p5sl + 1;
                   dff4p5sl(:,n4p5sl) = dff(:,v);
                   name4p5sl(n4p5sl)=filenames(v);
                 elseif nonlatcell(v) == 0
                   n4p5slc = n4p5slc + 1;
                   dff4p5slc(:,n4p5slc) = dff(:,v);
                   name4p5slc(n4p5slc)=filenames(v);
                 elseif nonfrontalsup(v) == 0
                   n4p5sfs = n4p5sfs + 1;
                   dff4p5sfs(:,n4p5sfs) = dff(:,v);
                   name4p5sfs(n4p5sfs)=filenames(v);
                 elseif nondorsaldeep(v) == 0
                   n4p5sdd = n4p5sdd + 1;
                   dff4p5sdd(:,n4p5sdd) = dff(:,v);
                   name4p5sdd(n4p5sdd)=filenames(v);
                 elseif nonfrontallat(v) == 0
                   n4p5sfl = n4p5sfl + 1;
                   dff4p5sfl(:,n4p5sfl) = dff(:,v);
                   name4p5sfl(n4p5sfl)=filenames(v);
                  elseif nondorsalsup(v) == 0
                   n4p5sds = n4p5sds + 1;
                   dff4p5sds(:,n4p5sds) = dff(:,v);
                   name4p5sds(n4p5sds)=filenames(v);
                  elseif nonmiddledeep(v) == 0
                   n4p5smd = n4p5smd + 1;
                   dff4p5smd(:,n4p5smd) = dff(:,v);
                   name4p5smd(n4p5smd)=filenames(v);
                  elseif nonconnect(v) == 0
                   n4p5sc = n4p5sc + 1;
                   dff4p5sc(:,n4p5sc) = dff(:,v);
                   name4p5sc(n4p5sc)=filenames(v);
                    
                  end   
              
            elseif non1p20s(v) == 0
                n1p20s = n1p20s+1;
               dff1p20s(:,n1p20s) =   dff(:,v);
               name1p20s(n1p20s)=filenames(v);
               if nonoverview(v) == 0
                   n1p20so = n1p20so + 1;
                   dff1p20so(:,n1p20so) = dff(:,v);
                   name1p20so(n1p20so)=filenames(v);
                elseif nonmiddlesup(v) == 0
                   n1p20sms = n1p20sms + 1;
                   dff1p20sms(:,n1p20sms) = dff(:,v);
                   name1p20sms(n1p20sms)=filenames(v);
                elseif nonlateral(v) == 0
                   n1p20sl = n1p20sl + 1;
                   dff1p20sl(:,n1p20sl) = dff(:,v);
                   name1p20sl(n1p20sl)=filenames(v);
                 elseif nonlatcell(v) == 0
                   n1p20slc = n1p20slc + 1;
                   dff1p20slc(:,n1p20slc) = dff(:,v);
                   name1p20slc(n1p20slc)=filenames(v);
                 elseif nonfrontalsup(v) == 0
                   n1p20sfs = n1p20sfs + 1;
                   dff1p20sfs(:,n1p20sfs) = dff(:,v);
                   name1p20sfs(n1p20sfs)=filenames(v);
                 elseif nondorsaldeep(v) == 0
                   n1p20sdd = n1p20sdd + 1;
                   dff1p20sdd(:,n1p20sdd) = dff(:,v);
                   name1p20sdd(n1p20sdd)=filenames(v);
                 elseif nonfrontallat(v) == 0
                   n1p20sfl = n1p20sfl + 1;
                   dff1p20sfl(:,n1p20sfl) = dff(:,v);
                   name1p20sfl(n1p20sfl)=filenames(v);
                  elseif nondorsalsup(v) == 0
                   n1p20sds = n1p20sds + 1;
                   dff1p20sds(:,n1p20sds) = dff(:,v);
                   name1p20sds(n1p20sds)=filenames(v);
                  elseif nonmiddledeep(v) == 0
                   n1p20smd = n1p20smd + 1;
                   dff1p20smd(:,n1p20smd) = dff(:,v);
                   name1p20smd(n1p20smd)=filenames(v);
                  elseif nonconnect(v) == 0
                   n1p20sc = n1p20sc + 1;
                   dff1p20sc(:,n1p20sc) = dff(:,v);
                   name1p20sc(n1p20sc)=filenames(v);
                    
                  end   
            elseif non2p20s(v) == 0
                n2p20s = n2p20s+1;
               dff2p20s(:,n2p20s) = dff(:,v);
               name2p20s(n2p20s)=filenames(v);
               if nonoverview(v) == 0
                   n2p20so = n2p20so + 1;
                   dff2p20so(:,n2p20so) = dff(:,v);
                   name2p20so(n2p20so)=filenames(v);
                elseif nonmiddlesup(v) == 0
                   n2p20sms = n2p20sms + 1;
                   dff2p20sms(:,n2p20sms) = dff(:,v);
                   name2p20sms(n2p20sms)=filenames(v);
                elseif nonlateral(v) == 0
                   n2p20sl = n2p20sl + 1;
                   dff2p20sl(:,n2p20sl) = dff(:,v);
                   name2p20sl(n2p20sl)=filenames(v);
                 elseif nonlatcell(v) == 0
                   n2p20slc = n2p20slc + 1;
                   dff2p20slc(:,n2p20slc) = dff(:,v);
                   name2p20slc(n2p20slc)=filenames(v);
                 elseif nonfrontalsup(v) == 0
                   n2p20sfs = n2p20sfs + 1;
                   dff2p20sfs(:,n2p20sfs) = dff(:,v);
                   name2p20sfs(n2p20sfs)=filenames(v);
                 elseif nondorsaldeep(v) == 0
                   n2p20sdd = n2p20sdd + 1;
                   dff2p20sdd(:,n2p20sdd) = dff(:,v);
                   name2p20sdd(n2p20sdd)=filenames(v);
                 elseif nonfrontallat(v) == 0
                   n2p20sfl = n2p20sfl + 1;
                   dff2p20sfl(:,n2p20sfl) = dff(:,v);
                   name2p20sfl(n2p20sfl)=filenames(v);
                  elseif nondorsalsup(v) == 0
                   n2p20sds = n2p20sds + 1;
                   dff2p20sds(:,n2p20sds) = dff(:,v);
                   name2p20sds(n2p20sds)=filenames(v);
                  elseif nonmiddledeep(v) == 0
                   n2p20smd = n2p20smd + 1;
                   dff2p20smd(:,n2p20smd) = dff(:,v);
                   name2p20smd(n2p20smd)=filenames(v);
                  elseif nonconnect(v) == 0
                   n2p20sc = n2p20sc + 1;
                   dff2p20sc(:,n2p20sc) = dff(:,v);
                   name2p20sc(n2p20sc)=filenames(v);
                    
                  end   
            elseif non4p1s(v) == 0
                n4p1s = n4p1s+1;
               dff4p1s(:,n4p1s) =   dff(:,v);
               name4p1s(n4p1s)=filenames(v);
               if nonoverview(v) == 0
                   n4p1so = n4p1so + 1;
                   dff4p1so(:,n4p1so) = dff(:,v);
                   name4p1so(n4p1so)=filenames(v);
                elseif nonmiddlesup(v) == 0
                   n4p1sms = n4p1sms + 1;
                   dff4p1sms(:,n4p1sms) = dff(:,v);
                   name4p1sms(n4p1sms)=filenames(v);
                elseif nonlateral(v) == 0
                   n4p1sl = n4p1sl + 1;
                   dff4p1sl(:,n4p1sl) = dff(:,v);
                   name4p1sl(n4p1sl)=filenames(v);
                 elseif nonlatcell(v) == 0
                   n4p1slc = n4p1slc + 1;
                   dff4p1slc(:,n4p1slc) = dff(:,v);
                   name4p1slc(n4p1slc)=filenames(v);
                 elseif nonfrontalsup(v) == 0
                   n4p1sfs = n4p1sfs + 1;
                   dff4p1sfs(:,n4p1sfs) = dff(:,v);
                   name4p1sfs(n4p1sfs)=filenames(v);
                 elseif nondorsaldeep(v) == 0
                   n4p1sdd = n4p1sdd + 1;
                   dff4p1sdd(:,n4p1sdd) = dff(:,v);
                   name4p1sdd(n4p1sdd)=filenames(v);
                 elseif nonfrontallat(v) == 0
                   n4p1sfl = n4p1sfl + 1;
                   dff4p1sfl(:,n4p1sfl) = dff(:,v);
                   name4p1sfl(n4p1sfl)=filenames(v);
                  elseif nondorsalsup(v) == 0
                   n4p1sds = n4p1sds + 1;
                   dff4p1sds(:,n4p1sds) = dff(:,v);
                   name4p1sds(n4p1sds)=filenames(v);
                  elseif nonmiddledeep(v) == 0
                   n4p1smd = n4p1smd + 1;
                   dff4p1smd(:,n4p1smd) = dff(:,v);
                   name4p1smd(n4p1smd)=filenames(v);
                  elseif nonconnect(v) == 0
                   n4p1sc = n4p1sc + 1;
                   dff4p1sc(:,n4p1sc) = dff(:,v);
                   name4p1sc(n4p1sc)=filenames(v);
                    
                  end   
                
            
            
           elseif non4p2s(v) == 0
                n4p2s = n4p2s+1;
               dff4p2s(:,n4p2s) =   dff(:,v);
               name4p2s(n4p2s)=filenames(v);
               if nonoverview(v) == 0
                   n4p2so = n4p2so + 1;
                   dff4p2so(:,n4p2so) = dff(:,v);
                   name4p2so(n4p2so)=filenames(v);
                elseif nonmiddlesup(v) == 0
                   n4p2sms = n4p2sms + 1;
                   dff4p2sms(:,n4p2sms) = dff(:,v);
                   name4p2sms(n4p2sms)=filenames(v);
                elseif nonlateral(v) == 0
                   n4p2sl = n4p2sl + 1;
                   dff4p2sl(:,n4p2sl) = dff(:,v);
                   name4p2sl(n4p2sl)=filenames(v);
                 elseif nonlatcell(v) == 0
                   n4p2slc = n4p2slc + 1;
                   dff4p2slc(:,n4p2slc) = dff(:,v);
                   name4p2slc(n4p2slc)=filenames(v);
                 elseif nonfrontalsup(v) == 0
                   n4p2sfs = n4p2sfs + 1;
                   dff4p2sfs(:,n4p2sfs) = dff(:,v);
                   name4p2sfs(n4p2sfs)=filenames(v);
                 elseif nondorsaldeep(v) == 0
                   n4p2sdd = n4p2sdd + 1;
                   dff4p2sdd(:,n4p2sdd) = dff(:,v);
                   name4p2sdd(n4p2sdd)=filenames(v);
                 elseif nonfrontallat(v) == 0
                   n4p2sfl = n4p2sfl + 1;
                   dff4p2sfl(:,n4p2sfl) = dff(:,v);
                   name4p2sfl(n4p2sfl)=filenames(v);
                  elseif nondorsalsup(v) == 0
                   n4p2sds = n4p2sds + 1;
                   dff4p2sds(:,n4p2sds) = dff(:,v);
                   name4p2sds(n4p2sds)=filenames(v);
                  elseif nonmiddledeep(v) == 0
                   n4p2smd = n4p2smd + 1;
                   dff4p2smd(:,n4p2smd) = dff(:,v);
                   name4p2smd(n4p2smd)=filenames(v);
                  elseif nonconnect(v) == 0
                   n4p2sc = n4p2sc + 1;
                   dff4p2sc(:,n4p2sc) = dff(:,v);
                   name4p2sc(n4p2sc)=filenames(v);
                    
                  end   
                
            end
        end
        
        warning('off','MATLAB:xlswrite:AddSheet')
        if exist('dff1p5s') == 1
            %make the output table
        T1p5s=table(dff1p5s);
       
        T1p5snames=table(name1p5s);
        mean1p5s=mean(dff1p5s,2);
         Tmean1p5s=table(mean1p5s);
        cd(outputdirv);% go to output directory
        %wirte the table to an excel spreadsheet; names are written to
        %second spreadsheet in the file
        writetable(T1p5s,outputfile1p5s,'Sheet',1,'WriteVariableNames',false);
        writetable(T1p5snames,outputfile1p5s,'Sheet',2,'WriteVariableNames',false);
         writetable(Tmean1p5s,outputfile1p5s,'Sheet','mean','WriteVariableNames',false);
        if exist('dff1p5so') ==1
            T1p5so=table(dff1p5so);
            writetable(T1p5so,outputfile1p5s,'Sheet','overview','WriteVariableNames',false); 
        end
        
         if exist('dff1p5sms') ==1
            T1p5sms=table(dff1p5sms);
            writetable(T1p5sms,outputfile1p5s,'Sheet','medial_superficial','WriteVariableNames',false); 
         end
          if exist('dff1p5sl') ==1
            T1p5sl=table(dff1p5sl);
            writetable(T1p5sl,outputfile1p5s,'Sheet','lateral_mid','WriteVariableNames',false); 
          end
         if exist('dff1p5slc') ==1
            T1p5slc=table(dff1p5slc);
            writetable(T1p5slc,outputfile1p5s,'Sheet','lateral_deep','WriteVariableNames',false); 
         end
         if exist('dff1p5sfs') ==1
            T1p5sfs=table(dff1p5sfs);
            writetable(T1p5sfs,outputfile1p5s,'Sheet','lateral_sup','WriteVariableNames',false); 
        end
         if exist('dff1p5sdd') ==1
            T1p5sdd=table(dff1p5sdd);
            writetable(T1p5sdd,outputfile1p5s,'Sheet','dorsal_deep','WriteVariableNames',false); 
         end
         if exist('dff1p5sfl') ==1
            T1p5sfl=table(dff1p5sfl);
            writetable(T1p5sfl,outputfile1p5s,'Sheet','frontal_lateral','WriteVariableNames',false); 
         end
         if exist('dff1p5sds') ==1
            T1p5sds=table(dff1p5sds);
            writetable(T1p5sds,outputfile1p5s,'Sheet','cellbodies','WriteVariableNames',false); 
         end
         if exist('dff1p5smd') ==1
            T1p5smd=table(dff1p5smd);
            writetable(T1p5smd,outputfile1p5s,'Sheet','medial_deep','WriteVariableNames',false); 
         end
         if exist('dff1p5sc') ==1
            T1p5sc=table(dff1p5sc);
            writetable(T1p5sc,outputfile1p5s,'Sheet','middle_connection','WriteVariableNames',false); 
        end
        
        %make output figure
        fig1p5s=figure();
        plot(dff1p5s);
        %legend(name1p5s,'Location','southeast');
        %save figure as eps in colours
        saveas(fig1p5s,outputimg1p5s,'epsc');
        
        end
        if exist('dff2p5s')==1 
        T2p5s=table(dff2p5s);
         T2p5snames=table(name2p5s);
         mean2p5s=mean(dff2p5s,2);
         Tmean2p5s=table(mean2p5s);
         
          cd(outputdirv); 
        writetable(T2p5s,outputfile2p5s,'Sheet',1,'WriteVariableNames',false);
        writetable(T2p5snames,outputfile2p5s,'Sheet',2,'WriteVariableNames',false);
         writetable(Tmean2p5s,outputfile2p5s,'Sheet','mean','WriteVariableNames',false); 
        if exist('dff2p5so') ==1
            T2p5so=table(dff2p5so);
            writetable(T2p5so,outputfile2p5s,'Sheet','overview','WriteVariableNames',false); 
        end
        
         if exist('dff2p5sms') ==1
            T2p5sms=table(dff2p5sms);
            writetable(T2p5sms,outputfile2p5s,'Sheet','medial_superficial','WriteVariableNames',false); 
         end
          if exist('dff2p5sl') ==1
            T2p5sl=table(dff2p5sl);
            writetable(T2p5sl,outputfile2p5s,'Sheet','lateral_mid','WriteVariableNames',false); 
          end
         if exist('dff2p5slc') ==1
            T2p5slc=table(dff2p5slc);
            writetable(T2p5slc,outputfile2p5s,'Sheet','lateral_deep','WriteVariableNames',false); 
         end
         if exist('dff2p5sfs') ==1
            T2p5sfs=table(dff2p5sfs);
            writetable(T2p5sfs,outputfile2p5s,'Sheet','lateral_sup','WriteVariableNames',false); 
        end
         if exist('dff2p5sdd') ==1
            T2p5sdd=table(dff2p5sdd);
            writetable(T2p5sdd,outputfile2p5s,'Sheet','dorsal_deep','WriteVariableNames',false); 
         end
         if exist('dff2p5sfl') ==1
            T2p5sfl=table(dff2p5sfl);
            writetable(T2p5sfl,outputfile2p5s,'Sheet','frontal_lateral','WriteVariableNames',false); 
         end
         if exist('dff2p5sds') ==1
            T2p5sds=table(dff2p5sds);
            writetable(T2p5sds,outputfile2p5s,'Sheet','cellbodies','WriteVariableNames',false); 
         end
         if exist('dff2p5smd') ==1
            T2p5smd=table(dff2p5smd);
            writetable(T2p5smd,outputfile2p5s,'Sheet','medial_deep','WriteVariableNames',false); 
         end
         if exist('dff2p5sc') ==1
            T2p5sc=table(dff2p5sc);
            writetable(T2p5sc,outputfile2p5s,'Sheet','middle_connection','WriteVariableNames',false); 
        end
      fig2p5s=figure();
        plot(dff2p5s);
        %legend(name2p5s,'Location','southeast');
        saveas(fig2p5s,outputimg2p5s,'epsc');
        end
       
        if exist('dff4p5s')==1
        T4p5s=table(dff4p5s);
         T4p5snames=table(name4p5s);
         mean4p5s=mean(dff4p5s,2);
         Tmean4p5s=table(mean4p5s);
         
           
         cd(outputdirv);
         writetable(T4p5s,outputfile4p5s,'Sheet',1,'WriteVariableNames',false);
        writetable(T4p5snames,outputfile4p5s,'Sheet',2,'WriteVariableNames',false);
        writetable(Tmean4p5s,outputfile4p5s,'Sheet','mean','WriteVariableNames',false);
       if exist('dff4p5so') ==1
            T4p5so=table(dff4p5so);
            writetable(T4p5so,outputfile4p5s,'Sheet','overview','WriteVariableNames',false); 
        end
        
         if exist('dff4p5sms') ==1
            T4p5sms=table(dff4p5sms);
            writetable(T4p5sms,outputfile4p5s,'Sheet','medial_superficial','WriteVariableNames',false); 
         end
          if exist('dff4p5sl') ==1
            T4p5sl=table(dff4p5sl);
            writetable(T4p5sl,outputfile4p5s,'Sheet','lateral_mid','WriteVariableNames',false); 
          end
         if exist('dff4p5slc') ==1
            T4p5slc=table(dff4p5slc);
            writetable(T4p5slc,outputfile4p5s,'Sheet','lateral_deep','WriteVariableNames',false); 
         end
         if exist('dff4p5sfs') ==1
            T4p5sfs=table(dff4p5sfs);
            writetable(T4p5sfs,outputfile4p5s,'Sheet','lateral_sup','WriteVariableNames',false); 
        end
         if exist('dff4p5sdd') ==1
            T4p5sdd=table(dff4p5sdd);
            writetable(T4p5sdd,outputfile4p5s,'Sheet','dorsal_deep','WriteVariableNames',false); 
         end
         if exist('dff4p5sfl') ==1
            T4p5sfl=table(dff4p5sfl);
            writetable(T4p5sfl,outputfile4p5s,'Sheet','frontal_lateral','WriteVariableNames',false); 
         end
         if exist('dff4p5sds') ==1
            T4p5sds=table(dff4p5sds);
            writetable(T4p5sds,outputfile4p5s,'Sheet','cellbodies','WriteVariableNames',false); 
         end
         if exist('dff4p5smd') ==1
            T4p5smd=table(dff4p5smd);
            writetable(T4p5smd,outputfile4p5s,'Sheet','medial_deep','WriteVariableNames',false); 
         end
         if exist('dff4p5sc') ==1
            T4p5sc=table(dff4p5sc);
            writetable(T4p5sc,outputfile4p5s,'Sheet','middle_connection','WriteVariableNames',false); 
        end
        fig4p5s=figure();
        plot(dff4p5s);
        %legend(name4p5s,'Location','southeast');
        saveas(fig4p5s,outputimg4p5s,'epsc');
        end
        if exist('dff1p20s')==1
        T1p20s=table(dff1p20s);
         T1p20snames=table(name1p20s);
           mean1p20s=mean(dff1p20s,2);
         Tmean1p20s=table(mean1p20s); 
         
         cd(outputdirv);
         writetable(T1p20s,outputfile1p20s,'Sheet',1,'WriteVariableNames',false);
        writetable(T1p20snames,outputfile1p20s,'Sheet',2,'WriteVariableNames',false);
        writetable(Tmean1p20s,outputfile1p20s,'Sheet','mean','WriteVariableNames',false);
        if exist('dff1p20so') ==1
            T1p20so=table(dff1p20so);
            writetable(T1p20so,outputfile1p20s,'Sheet','overview','WriteVariableNames',false); 
        end
        
         if exist('dff1p20sms') ==1
            T1p20sms=table(dff1p20sms);
            writetable(T1p20sms,outputfile1p20s,'Sheet','medial_superficial','WriteVariableNames',false); 
         end
          if exist('dff1p20sl') ==1
            T1p20sl=table(dff1p20sl);
            writetable(T1p20sl,outputfile1p20s,'Sheet','lateral_mid','WriteVariableNames',false); 
          end
         if exist('dff1p20slc') ==1
            T1p20slc=table(dff1p20slc);
            writetable(T1p20slc,outputfile1p20s,'Sheet','lateral_deep','WriteVariableNames',false); 
         end
         if exist('dff1p20sfs') ==1
            T1p20sfs=table(dff1p20sfs);
            writetable(T1p20sfs,outputfile1p20s,'Sheet','lateral_sup','WriteVariableNames',false); 
        end
         if exist('dff1p20sdd') ==1
            T1p20sdd=table(dff1p20sdd);
            writetable(T1p20sdd,outputfile1p20s,'Sheet','dorsal_deep','WriteVariableNames',false); 
         end
         if exist('dff1p20sfl') ==1
            T1p20sfl=table(dff1p20sfl);
            writetable(T1p20sfl,outputfile1p20s,'Sheet','frontal_lateral','WriteVariableNames',false); 
         end
         if exist('dff1p20sds') ==1
            T1p20sds=table(dff1p20sds);
            writetable(T1p20sds,outputfile1p20s,'Sheet','cellbodies','WriteVariableNames',false); 
         end
         if exist('dff1p20smd') ==1
            T1p20smd=table(dff1p20smd);
            writetable(T1p20smd,outputfile1p20s,'Sheet','medial_deep','WriteVariableNames',false); 
         end
         if exist('dff1p20sc') ==1
            T1p20sc=table(dff1p20sc);
            writetable(T1p20sc,outputfile1p20s,'Sheet','middle_connection','WriteVariableNames',false); 
        end
        
        fig1p20s=figure();
        plot(dff1p20s);
        %legend(name1p20s,'Location','southeast');
        saveas(fig1p20s,outputimg1p20s,'epsc');
        end
        if exist('dff2p20s')==1
        T2p20s=table(dff2p20s);
         T2p20snames=table(name2p20s);
           mean2p20s=mean(dff2p20s,2);
         Tmean2p20s=table(mean2p20s); 
         cd(outputdirv);
         writetable(T2p20s,outputfile2p20s,'Sheet',1,'WriteVariableNames',false);
        writetable(T2p20snames,outputfile2p20s,'Sheet',2,'WriteVariableNames',false);
        writetable(Tmean2p20s,outputfile2p20s,'Sheet','mean','WriteVariableNames',false);
        if exist('dff2p20so') ==1
            T2p20so=table(dff2p20so);
            writetable(T2p20so,outputfile2p20s,'Sheet','overview','WriteVariableNames',false); 
        end
        
         if exist('dff2p20sms') ==1
            T2p20sms=table(dff2p20sms);
            writetable(T2p20sms,outputfile2p20s,'Sheet','medial_superficial','WriteVariableNames',false); 
         end
          if exist('dff2p20sl') ==1
            T2p20sl=table(dff2p20sl);
            writetable(T2p20sl,outputfile2p20s,'Sheet','lateral_mid','WriteVariableNames',false); 
          end
         if exist('dff2p20slc') ==1
            T2p20slc=table(dff2p20slc);
            writetable(T2p20slc,outputfile2p20s,'Sheet','lateral_deep','WriteVariableNames',false); 
         end
         if exist('dff2p20sfs') ==1
            T2p20sfs=table(dff2p20sfs);
            writetable(T2p20sfs,outputfile2p20s,'Sheet','lateral_sup','WriteVariableNames',false); 
        end
         if exist('dff2p20sdd') ==1
            T2p20sdd=table(dff2p20sdd);
            writetable(T2p20sdd,outputfile2p20s,'Sheet','dorsal_deep','WriteVariableNames',false); 
         end
         if exist('dff2p20sfl') ==1
            T2p20sfl=table(dff2p20sfl);
            writetable(T2p20sfl,outputfile2p20s,'Sheet','frontal_lateral','WriteVariableNames',false); 
         end
         if exist('dff2p20sds') ==1
            T2p20sds=table(dff2p20sds);
            writetable(T2p20sds,outputfile2p20s,'Sheet','cellbodies','WriteVariableNames',false); 
         end
         if exist('dff2p20smd') ==1
            T2p20smd=table(dff2p20smd);
            writetable(T2p20smd,outputfile2p20s,'Sheet','medial_deep','WriteVariableNames',false); 
         end
         if exist('dff2p20sc') ==1
            T2p20sc=table(dff2p20sc);
            writetable(T2p20sc,outputfile2p20s,'Sheet','middle_connection','WriteVariableNames',false); 
        end
        fig2p20s=figure();
        plot(dff2p20s);
        %legend(name2p20s,'Location','southeast');
        saveas(fig2p20s,outputimg2p20s,'epsc');
        end
        if exist('dff4p1s')==1
        T4p1s=table(dff4p1s);
         T4p1snames=table(name4p1s);
           mean4p1s=mean(dff4p1s,2);
         Tmean4p1s=table(mean4p1s); 
         cd(outputdirv);
         writetable(T4p1s,outputfile4p1s,'Sheet',1,'WriteVariableNames',false);
        writetable(T4p1snames,outputfile4p1s,'Sheet',2,'WriteVariableNames',false);
       writetable(Tmean4p1s,outputfile4p1s,'Sheet','mean','WriteVariableNames',false);
        if exist('dff4p1so') ==1
            T4p1so=table(dff4p1so);
            writetable(T4p1so,outputfile4p1s,'Sheet','overview','WriteVariableNames',false); 
        end
        
         if exist('dff4p1sms') ==1
            T4p1sms=table(dff4p1sms);
            writetable(T4p1sms,outputfile4p1s,'Sheet','medial_superficial','WriteVariableNames',false); 
         end
          if exist('dff4p1sl') ==1
            T4p1sl=table(dff4p1sl);
            writetable(T4p1sl,outputfile4p1s,'Sheet','lateral_mid','WriteVariableNames',false); 
          end
         if exist('dff4p1slc') ==1
            T4p1slc=table(dff4p1slc);
            writetable(T4p1slc,outputfile4p1s,'Sheet','lateral_deep','WriteVariableNames',false); 
         end
         if exist('dff4p1sfs') ==1
            T4p1sfs=table(dff4p1sfs);
            writetable(T4p1sfs,outputfile4p1s,'Sheet','lateral_sup','WriteVariableNames',false); 
        end
         if exist('dff4p1sdd') ==1
            T4p1sdd=table(dff4p1sdd);
            writetable(T4p1sdd,outputfile4p1s,'Sheet','dorsal_deep','WriteVariableNames',false); 
         end
         if exist('dff4p1sfl') ==1
            T4p1sfl=table(dff4p1sfl);
            writetable(T4p1sfl,outputfile4p1s,'Sheet','frontal_lateral','WriteVariableNames',false); 
         end
         if exist('dff4p1sds') ==1
            T4p1sds=table(dff4p1sds);
            writetable(T4p1sds,outputfile4p1s,'Sheet','cellbodies','WriteVariableNames',false); 
         end
         if exist('dff4p1smd') ==1
            T4p1smd=table(dff4p1smd);
            writetable(T4p1smd,outputfile4p1s,'Sheet','medial_deep','WriteVariableNames',false); 
         end
         if exist('dff4p1sc') ==1
            T4p1sc=table(dff4p1sc);
            writetable(T4p1sc,outputfile4p1s,'Sheet','middle_connection','WriteVariableNames',false); 
        end
        fig4p1s=figure();
        plot(dff4p1s);
        %legend(name4p1s,'Location','southeast');
        saveas(fig4p1s,outputimg4p1s,'epsc');
        end
        if exist('dff4p2s')==1
        T4p2s=table(dff4p2s);
         T4p2snames=table(name4p2s);
           mean4p2s=mean(dff4p2s,2);
         Tmean4p2s=table(mean4p2s); 
         cd(outputdirv);
         writetable(T4p2s,outputfile4p2s,'Sheet',1,'WriteVariableNames',false);
        writetable(T4p2snames,outputfile4p2s,'Sheet',2,'WriteVariableNames',false);
       writetable(Tmean4p2s,outputfile4p2s,'Sheet','mean','WriteVariableNames',false);
        if exist('dff4p2so') ==1
            T4p2so=table(dff4p2so);
            writetable(T4p2so,outputfile4p2s,'Sheet','overview','WriteVariableNames',false); 
        end
        
         if exist('dff4p2sms') ==1
            T4p2sms=table(dff4p2sms);
            writetable(T4p2sms,outputfile4p2s,'Sheet','medial_superficial','WriteVariableNames',false); 
         end
          if exist('dff4p2sl') ==1
            T4p2sl=table(dff4p2sl);
            writetable(T4p2sl,outputfile4p2s,'Sheet','lateral_mid','WriteVariableNames',false); 
          end
         if exist('dff4p2slc') ==1
            T4p2slc=table(dff4p2slc);
            writetable(T4p2slc,outputfile4p2s,'Sheet','lateral_deep','WriteVariableNames',false); 
         end
         if exist('dff4p2sfs') ==1
            T4p2sfs=table(dff4p2sfs);
            writetable(T4p2sfs,outputfile4p2s,'Sheet','lateral_sup','WriteVariableNames',false); 
        end
         if exist('dff4p2sdd') ==1
            T4p2sdd=table(dff4p2sdd);
            writetable(T4p2sdd,outputfile4p2s,'Sheet','dorsal_deep','WriteVariableNames',false); 
         end
         if exist('dff4p2sfl') ==1
            T4p2sfl=table(dff4p2sfl);
            writetable(T4p2sfl,outputfile4p2s,'Sheet','frontal_lateral','WriteVariableNames',false); 
         end
         if exist('dff4p2sds') ==1
            T4p2sds=table(dff4p2sds);
            writetable(T4p2sds,outputfile4p2s,'Sheet','cellbodies','WriteVariableNames',false); 
         end
         if exist('dff4p2smd') ==1
            T4p2smd=table(dff4p2smd);
            writetable(T4p2smd,outputfile4p2s,'Sheet','medial_deep','WriteVariableNames',false); 
         end
         if exist('dff4p2sc') ==1
            T4p2sc=table(dff4p2sc);
            writetable(T4p2sc,outputfile4p2s,'Sheet','middle_connection','WriteVariableNames',false); 
        end
        fig4p2s=figure();
        plot(dff4p2s);
        %legend(name4p1s,'Location','southeast');
        saveas(fig4p2s,outputimg4p2s,'epsc');
        end
        %go back to directory of matlab scripts
        cd(startdir);



