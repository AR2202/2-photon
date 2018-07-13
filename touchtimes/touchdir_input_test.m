%Annika Rings August 2017
%This is a test script for reading in touchtimes files from a directory
touchdir = ('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/dsx-GABA-female_male_touch/touchtimes_files');
% The folder where the touchtimes files are located
resultsdir = ('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/dsx-GABA-female_male_touch/Results_dsx-GABA');
% The folder where the results of single experiments are located
outputdirmean=('/Users/annika/Documents/projects/dsx_GABAergic_neurons/imaging/dsx-GABA-female_male_touch/Results_mean');
%The folder where the mean data should be written to
%go to touchdirectory
cd(touchdir)
%get filenames form the directory
files = dir('*.xlsx');

files = {files.name};
%read in all the touchtimes from the files
touchtimes=cellfun(@(filename) table2array(readtable(filename,'Range','E:E','ReadVariableNames',1)), files, 'UniformOutput', false);

resultfilestrings=cellfun(@(filename) strrep((regexprep(filename,'_(\d+).xlsx','_')),'touchtimes_',''), files, 'UniformOutput', false);
numberstrings=cellfun(@(filename) strrep((regexprep(filename,'touchtimes_(\d+)_(\d+)_(\d+)_','')),'.xlsx',''), files, 'UniformOutput', false);
               
cd(resultsdir);
resultfiles = cellfun(@(resultfilestring) dir(strcat(resultfilestring,'*.xlsx')), resultfilestrings, 'UniformOutput', false);
resultfiles = cellfun(@(resultfile) {resultfile.name}, resultfiles, 'UniformOutput', false);

resultfilenames=cellfun(@(resultfile) resultfile, {resultfiles}, 'UniformOutput', false);
expnames=cellfun(@(resultfile) cellfun(@(resultf) table2array(readtable(resultf,'Sheet','Sheet2','ReadVariableNames',0)), resultfile, 'UniformOutput', false), resultfiles, 'UniformOutput', false);
foundstr=cellfun(@(numbers,files) cellfun(@(resultsfiles) cellfun(@(exp) contains(exp,numbers),resultsfiles), files,'UniformOutput', false),numberstrings, expnames, 'UniformOutput', false);
[found]=cellfun(@(numbers,files) cellfun(@(resultsfiles) cellfun(@(exp) foundstringnames(exp,numbers),resultsfiles, 'Uniformoutput', false), files,'UniformOutput', false),numberstrings, expnames, 'UniformOutput', false);
[foundin,foundfilename,fileindex]= cellfun(@(exps,nums,rfiles) findfounds2(exps,nums,rfiles), expnames, numberstrings,resultfiles,'UniformOutput',false);
 
 imagingfilestrings=string(foundfilename);
 %fileindexstr=string(fileindex);
 %foundinstr=string(foundin);
 all_expresults=cellfun(@(foundname,foundindex) resultfinder(string(foundname),foundindex{1,1}), foundin,fileindex,'UniformOutput',false);
% t_touchtimes=transpose(touchtimes) ; 
% t_expresults=transpose(all_expresults);  
 %data_array=t_touchtimes,t_expresults};  
 data_array=cellfun(@(data1,data2) {transpose(data1),transpose(data2)}, touchtimes, all_expresults,'UniformOutput', false);  
                      

                    
                      
                       function [foundexp]= foundstringnames(expname,numberstring)
                         if contains(expname,numberstring) == 1
                         
                           foundexp = expname;
                           
                           
                       else
                       foundexp = [];
                       end
                       

                       end
                       function [ffounds,index]=findfounds(exparray,numbarray)
                       ffounds=cellfun(@(exp) foundstringnames(exp,numbarray), exparray,'UniformOutput',false);
                       
                       index=find(~cellfun('isempty',ffounds));
                       ffounds=ffounds(~cellfun('isempty',ffounds));
                      
                       end
                       function [foundinfiles,fffounds,iindex]=findfounds2(resultsarray,numbarray,rresultfilenames)
                       [fffounds,iindex]=cellfun(@(resultsfiles) findfounds(resultsfiles,numbarray), resultsarray,'UniformOutput', false);
                      
                       for i=1:length(resultsarray)
                       if isempty(fffounds{i})==1
                          foundinfiles{i}=[];
                       else
                           
                            foundinfiles{i}=rresultfilenames{i};
                       end
                       end
                       fffounds=fffounds(~cellfun('isempty',fffounds));
                        foundinfiles=foundinfiles(~cellfun('isempty',foundinfiles));
                        iindex=iindex(~cellfun('isempty',iindex));
                      
                     
                       
                       end
                       function[singleresult]=resultfinder(nameoffile,indexoffile)
                       
                       expresults =table2array(readtable(nameoffile,'Sheet','Sheet1','ReadVariableNames',0));
                        singleresult=expresults(:,indexoffile);
 
                       end