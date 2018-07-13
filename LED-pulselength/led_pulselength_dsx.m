
clear all; 

%% 1. Set constants, variables and local functions

extracting = @mean; % taking the mean of each frame
framerate = 5.92; % frame rate in Hz

numberframes=600;
duration_acquisition = numberframes/framerate; 
x = (1:numberframes)';% this is a column vector of the frame numbers
x= (x-1)/framerate;%calculate the timepoints of the frames from the frame number

baseline_start = 2;
baseline_end = 11;
startdir=pwd;
pathname='/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/dsx-FLP_Gad1-lexA-ReachR_P1-GCaMP6s/imaging_preprocessed';
%pathname has to be the path to the folder were files to be processed are
%located
foldername='2018_02_01';%the name of the imaging folder
subfoldername='good_examples';%must be a folder within the imaging folder
stackdir = fullfile(pathname,foldername,subfoldername);
outputdirv=('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/dsx-FLP_Gad1-lexA-ReachR_P1-GCaMP6s/Results');
outputfile1p5s=strcat(foldername,'_LED_off.xlsx');
outputimg1p5s=strcat(foldername,'_LED_off.eps');
outputfile2p5s=strcat(foldername,'_2p05s.xlsx');
outputimg2p5s=strcat(foldername,'_2p05s.eps');
outputfile4p5s=strcat(foldername,'_4p05s.xlsx');
outputimg4p5s=strcat(foldername,'_4p05s.eps');
outputfile1p20s=strcat(foldername,'_1p20s.xlsx');
outputimg1p20s=strcat(foldername,'_1p20s.eps');
outputfile2p20s=strcat(foldername,'_2p20s.xls');
outputimg2p20s=strcat(foldername,'_2p20s.eps');
outputfile4p1s=strcat(foldername,'_4p01s.xlsx');
outputimg4p1s=strcat(foldername,'_4p01s.eps');
outputfile1p1s=strcat(foldername,'_1p01s.xlsx');
outputimg1p1s=strcat(foldername,'_1p01s.eps');

ee = 1;
ii = 1;
n1p5s = 0;
n2p5s = 0;
n4p5s =0;
n1p20s =0;
n2p20s =0;
n4p1s =0;
n1p1s =0;

 n1p5sn = 0;
 n1p5slc = 0;
 n1p5sc =0;
 
 n2p5sn = 0;
 n2p5slc = 0;
 n2p5sc =0;
 
 n4p5sn = 0;
 n4p5slc = 0;
 n4p5sc =0;
 
 n1p20sn = 0;
 n1p20slc = 0;
 n1p20sc =0;
    
n2p20sn = 0;
n2p20slc = 0;
n2p20sc =0;
    
n4p1sn = 0;
 n4p1slc = 0;
 n4p1sc =0;
  
 n1p1sn = 0;
 n1p1slc = 0;
 n1p1sc =0;
  
  
  


pulsetimes1p5s=[40];
pulsetimes1p20s=[40];
pulsetimes2p5s=[30,60];
pulsetimes4p5s=[20,40,60,80];
pulsetimes2p20s=[20,60];
pulsetimes4p1s=[20,40,60,80];
pulsetimes1p1s=[40];







 


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
        %this is completely stupid - clean up!
        
        f1p5s = strfind(filenames,'LED_off');
        f2p5s = strfind(filenames, '2pulse5s');
        f4p5s = strfind(filenames, '4pulse5s');
        f1p20s = strfind(filenames, '1pulse20s');
        f2p20s = strfind(filenames, '2pulse20s');
        f4p1s = strfind(filenames, '4pulse1s');
        f1p1s = strfind(filenames, '1pulse1s');
        
        
        non1p5s = cellfun('isempty',f1p5s);
        non2p5s = cellfun('isempty',f2p5s);
        non4p5s = cellfun('isempty',f4p5s);
        non1p20s = cellfun('isempty',f1p20s);
        non2p20s = cellfun('isempty',f2p20s);
        non4p1s = cellfun('isempty',f4p1s);
        non1p1s = cellfun('isempty',f1p1s);
        
        %finding recording location specifications in the file name
       
        flatcell = strfind(filenames,'cellbodies');
        notouch = strfind(filenames,'dendrite_no_touch');
        
        fconnect = strfind(filenames,'touch_female');
        
       
        nonlatcell = cellfun('isempty',flatcell);
        nonnotouch = cellfun('isempty',notouch);
        nonconnect = cellfun('isempty',fconnect);
        
        for v = 1:length(filenames)
            if non1p5s(v) == 0 %if the file has a 1pulse_5s pulse protocol
               
                n1p5s =n1p5s+1;
                dff1p5s(:,n1p5s) =   dff(:,v); %make a new matrix to safe dff of all files with this pulse protocol
                name1p5s(n1p5s)=filenames(v);
               
                 if nonlatcell(v) == 0
                   n1p5slc = n1p5slc + 1;
                   dff1p5slc(:,n1p5slc) = dff(:,v);
                   name1p5slc(n1p5slc)=filenames(v);
                
                  elseif nonconnect(v) == 0
                   n1p5sc = n1p5sc + 1;
                   dff1p5sc(:,n1p5sc) = dff(:,v);
                   name1p5sc(n1p5sc)=filenames(v);
                  elseif nonnotouch(v) == 0
                   n1p5sn = n1p5sn + 1;
                   dff1p5sn(:,n1p5sn) = dff(:,v);
                   name1p5sn(n1p5sn)=filenames(v);
                    
                  end   
               
            elseif non2p5s(v) == 0
                n2p5s = n2p5s+1;
                dff2p5s(:,n2p5s) =   dff(:,v);
                name2p5s(n2p5s)=filenames(v);
                
                if nonlatcell(v) == 0
                   n2p5slc = n2p5slc + 1;
                   dff2p5slc(:,n2p5slc) = dff(:,v);
                   name2p5slc(n2p5slc)=filenames(v);
                
                  elseif nonconnect(v) == 0
                   n2p5sc = n2p5sc + 1;
                   dff2p5sc(:,n2p5sc) = dff(:,v);
                   name2p5sc(n2p5sc)=filenames(v);
                   elseif nonnotouch(v) == 0
                   n2p5sn = n2p5sn + 1;
                   dff2p5sn(:,n2p5sn) = dff(:,v);
                   name2p5sn(n2p5sn)=filenames(v);
                    
                  end   
               
            elseif non4p5s(v) == 0
                n4p5s = n4p5s+1;
               dff4p5s(:,n4p5s) =   dff(:,v);
               name4p5s(n4p5s)=filenames(v);
              
                 if nonlatcell(v) == 0
                   n4p5slc = n4p5slc + 1;
                   dff4p5slc(:,n4p5slc) = dff(:,v);
                   name4p5slc(n4p5slc)=filenames(v);
                 
                  elseif nonconnect(v) == 0
                   n4p5sc = n4p5sc + 1;
                   dff4p5sc(:,n4p5sc) = dff(:,v);
                   name4p5sc(n4p5sc)=filenames(v);
                   elseif nonnotouch(v) == 0
                   n4p5sn = n4p5sn + 1;
                   dff4p5sn(:,n4p5sn) = dff(:,v);
                   name4p5sn(n4p5sn)=filenames(v);
                    
                  end   
              
            elseif non1p20s(v) == 0
                n1p20s = n1p20s+1;
               dff1p20s(:,n1p20s) =   dff(:,v);
               name1p20s(n1p20s)=filenames(v);
               
                if nonlatcell(v) == 0
                   n1p20slc = n1p20slc + 1;
                   dff1p20slc(:,n1p20slc) = dff(:,v);
                   name1p20slc(n1p20slc)=filenames(v);
                 
                  elseif nonconnect(v) == 0
                   n1p20sc = n1p20sc + 1;
                   dff1p20sc(:,n1p20sc) = dff(:,v);
                   name1p20sc(n1p20sc)=filenames(v);
                   
                   elseif nonnotouch(v) == 0
                   n1p20sn = n1p20sn + 1;
                   dff1p20sn(:,n1p20sn) = dff(:,v);
                   name1p20sn(n1p20sn)=filenames(v);
                    
                  end   
            elseif non2p20s(v) == 0
                n2p20s = n2p20s+1;
               dff2p20s(:,n2p20s) = dff(:,v);
               name2p20s(n2p20s)=filenames(v);
               
                if nonlatcell(v) == 0
                   n2p20slc = n2p20slc + 1;
                   dff2p20slc(:,n2p20slc) = dff(:,v);
                   name2p20slc(n2p20slc)=filenames(v);
                
                  elseif nonconnect(v) == 0
                   n2p20sc = n2p20sc + 1;
                   dff2p20sc(:,n2p20sc) = dff(:,v);
                   name2p20sc(n2p20sc)=filenames(v);
                   elseif nonnotouch(v) == 0
                   n2p20sn = n2p20sn + 1;
                   dff2p20sn(:,n2p20sn) = dff(:,v);
                   name2p20sn(n2p20sn)=filenames(v);
                    
                  end   
            elseif non4p1s(v) == 0
                n4p1s = n4p1s+1;
               dff4p1s(:,n4p1s) =   dff(:,v);
               name4p1s(n4p1s)=filenames(v);
               
                 if nonlatcell(v) == 0
                   n4p1slc = n4p1slc + 1;
                   dff4p1slc(:,n4p1slc) = dff(:,v);
                   name4p1slc(n4p1slc)=filenames(v);
                
                  
                  elseif nonconnect(v) == 0
                   n4p1sc = n4p1sc + 1;
                   dff4p1sc(:,n4p1sc) = dff(:,v);
                   name4p1sc(n4p1sc)=filenames(v);
                   elseif nonnotouch(v) == 0
                   n4p1sn = n4p1sn + 1;
                   dff4p1sn(:,n4p1sn) = dff(:,v);
                   name4p1sn(n4p1sn)=filenames(v);
                    
                  end   
                
            
            
           elseif non1p1s(v) == 0
                n1p1s = n1p1s+1;
               dff1p1s(:,n1p1s) =   dff(:,v);
               name1p1s(n1p1s)=filenames(v);
               
                 if nonlatcell(v) == 0
                   n1p1slc = n1p1slc + 1;
                   dff1p1slc(:,n1p1slc) = dff(:,v);
                   name1p1slc(n1p1slc)=filenames(v);
                 
                  elseif nonconnect(v) == 0
                   n1p1sc = n1p1sc + 1;
                   dff1p1sc(:,n1p1sc) = dff(:,v);
                   name1p1sc(n1p1sc)=filenames(v);
                   elseif nonnotouch(v) == 0
                   n1p1sn = n1p1sn + 1;
                   dff1p1sn(:,n1p1sn) = dff(:,v);
                   name1p1sn(n1p1sn)=filenames(v);
                    
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
       
         if exist('dff1p5slc') ==1
            T1p5slc=table(dff1p5slc);
            writetable(T1p5slc,outputfile1p5s,'Sheet','cellbodies_no_touch','WriteVariableNames',false); 
         end
         
         if exist('dff1p5sc') ==1
            T1p5sc=table(dff1p5sc);
            writetable(T1p5sc,outputfile1p5s,'Sheet','touch_female','WriteVariableNames',false); 
        end
         if exist('dff1p5sn') ==1
            T1p5sn=table(dff1p5sn);
            writetable(T1p5sn,outputfile1p5s,'Sheet','no_touch','WriteVariableNames',false); 
        end
        %make output figure
        fig1p5s=figure('Name','LED_off');
        plot(x,dff1p5s);
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
        if exist('dff2p5slc') ==1
            T1p5slc=table(dff1p5slc);
            writetable(T1p5slc,outputfile1p5s,'Sheet','cellbodies_no_touch','WriteVariableNames',false); 
         end
         
         if exist('dff2p5sc') ==1
            T2p5sc=table(dff2p5sc);
            writetable(T2p5sc,outputfile2p5s,'Sheet','touch_female','WriteVariableNames',false); 
        end
         if exist('dff2p5sn') ==1
            T2p5sn=table(dff2p5sn);
            writetable(T2p5sn,outputfile2p5s,'Sheet','no_touch','WriteVariableNames',false); 
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
       if exist('dff4p5slc') ==1
            T4p5slc=table(dff4p5slc);
            writetable(T4p5slc,outputfile4p5s,'Sheet','cellbodies_no_touch','WriteVariableNames',false); 
         end
         
         if exist('dff4p5sc') ==1
            T4p5sc=table(dff4p5sc);
            writetable(T4p5sc,outputfile4p5s,'Sheet','touch_female','WriteVariableNames',false); 
        end
         if exist('dff4p5sn') ==1
            T4p5sn=table(dff4p5sn);
            writetable(T4p5sn,outputfile4p5s,'Sheet','no_touch','WriteVariableNames',false); 
        end
        fig4p5s=figure('Name','4pulse05s');
        plot(x,dff4p5s);
        pulsedur=5;
        for numpatch = 1:size(pulsetimes4p5s,2)
             hpatch(numpatch)=patch([pulsetimes4p5s(numpatch) pulsetimes4p5s(numpatch)+pulsedur pulsetimes4p5s(numpatch)+pulsedur pulsetimes4p5s(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
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
        if exist('dff1p20slc') ==1
            T1p20slc=table(dff1p20slc);
            writetable(T1p20slc,outputfile1p20s,'Sheet','cellbodies_no_touch','WriteVariableNames',false); 
         end
         
         if exist('dff1p20sc') ==1
            T1p20sc=table(dff1p20sc);
            writetable(T1p20sc,outputfile1p20s,'Sheet','touch_female','WriteVariableNames',false); 
        end
         if exist('dff1p20sn') ==1
            T1p20sn=table(dff1p20sn);
            writetable(T1p20sn,outputfile1p20s,'Sheet','no_touch','WriteVariableNames',false); 
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
        if exist('dff2p20slc') ==1
            T2p20slc=table(dff2p20slc);
            writetable(T2p20slc,outputfile2p20s,'Sheet','cellbodies_no_touch','WriteVariableNames',false); 
         end
         
         if exist('dff2p20sc') ==1
            T2p20sc=table(dff2p20sc);
            writetable(T2p20sc,outputfile2p20s,'Sheet','touch_female','WriteVariableNames',false); 
        end
         if exist('dff2p20sn') ==1
            T2p20sn=table(dff2p20sn);
            writetable(T2p20sn,outputfile2p20s,'Sheet','no_touch','WriteVariableNames',false); 
        end
        fig2p20s=figure('Name','2pulse20s');
        plot(x,dff2p20s);
         pulsedur=20;
        for numpatch = 1:size(pulsetimes2p20s,2)
             hpatch(numpatch)=patch([pulsetimes2p20s(numpatch) pulsetimes2p20s(numpatch)+pulsedur pulsetimes2p20s(numpatch)+pulsedur pulsetimes2p20s(numpatch)] , [min(ylim)*[1 1] max(ylim)*[1 1]],'c','EdgeColor','none');
            
             uistack(hpatch(numpatch), 'bottom');
            end
        %legend(name2p20s,'Location','southeast');
        saveas(fig2p20s,outputimg2p20s,'epsc');
        end
       
        
        %go back to directory of matlab scripts
        cd(startdir);



