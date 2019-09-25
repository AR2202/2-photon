currentdir = pwd;
touchdir = ('/Volumes/LaCie/Projects/aDN/imaging/aDN_touch/touchtimes_GCaMP6s_l_r_reduced');
% The folder where the touchtimes files are located

outputdir=('/Volumes/LaCie/Projects/aDN/imaging/aDN_touch/touchtimes_full_test');



%This part of the script reads in the data
lateralized = 0;
if contains (touchdir, '_l_r_')
    lateralized = 1;
end

reduced=0;
if contains (touchdir, 'reduced')
    reduced =1;
end

%go to touchdirectory
cd(touchdir)
%get filenames form the directory
files = dir('*.xlsx');

files = {files.name};
%read in all the touchtimes from the files
touchtimes=cellfun(@(filename) table2array(readtable(filename,'Range','E:E','ReadVariableNames',1)), files, 'UniformOutput', false);
if lateralized
    touchtimes_r=cellfun(@(filename) table2array(readtable(filename,'Range','I:I','ReadVariableNames',1)), files, 'UniformOutput', false);
else
    touchtimes_r = touchtimes;
end
if reduced
    disp ('reduced touchtime format was used.');
    touchtimes=cellfun(@(testtimes) expand_reduced_touchtimes(testtimes),touchtimes,'UniformOutput',false);
    touchtimes_r=cellfun(@(testtimes) expand_reduced_touchtimes(testtimes),touchtimes_r,'UniformOutput',false);
    touchtimes=transpose(touchtimes);
    touchtimes_r=transpose(touchtimes_r);
    touchtimes_pooled = cellfun(@(touchtimesl,touchtimesr) unique(sort(vertcat(touchtimesl,touchtimesr))),touchtimes,touchtimes_r,'UniformOutput',false);
    files = transpose(files);
    Tables=cellfun(@(touchtime,filename)totable(touchtime,filename,outputdir,'E:E'),touchtimes,files,'uni',false);
    Tables_r=cellfun(@(touchtime,filename)totable(touchtime,filename,outputdir,'I:I'),touchtimes_r,files,'uni',false);
    Tables_pooled=cellfun(@(touchtime,filename)totable(touchtime,filename,outputdir,'E:E'),touchtimes_pooled,files,'uni',false);
    cd (currentdir);
end
function Ttouchtimes=totable(touchtimes,outputfile,outputdir,range)
Ttouchtimes=table(touchtimes);
         
         cd(outputdir);
         writetable(Ttouchtimes,outputfile,'Sheet',1,'WriteVariableNames',true,'Range',range);
end
        

function[outputtimes]=expand_reduced_touchtimes(testtimes)
                       outputtimes=[];
                       
                       for i=1:2:length(testtimes)-1
                           %exclude touch periods > 5s
                           if (testtimes(i+1)-testtimes(i))<6
                               
                               for j=0:round(testtimes(i+1)-testtimes(i))
                                   outputtimes=[outputtimes;(testtimes(i)+j)];
                               end
                           end
                       end
                       end