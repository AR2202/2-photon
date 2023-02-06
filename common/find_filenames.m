function find_filenames(dirname)
outname = strcat(dirname, '.xlsx');
allfiles= dir(dirname);
filenames ={};
for p = 1: length(allfiles)
    filename = allfiles(p).name;
    fileisdir = allfiles(p).isdir;
    if startsWith(filename, '.')
                continue;
            end
    if fileisdir
        if ismember(filename, {'.', '..','video'})
            continue;
        end
        allsubfiles = dir(fullfile(dirname,filename));
        for q = 1: length(allsubfiles)
            subfilename = allsubfiles(q).name;
            if ismember(subfilename, {'.', '..'})
                continue;
            end
            if startsWith(subfilename, '.')
                continue;
            end
            filenames{end + 1} = subfilename;
        end
    
    else
            filenames{end + 1} = filename;
    end
        end
      
        T = cell2table(transpose(filenames));
        T.Properties.VariableNames = ["filename"];
        disp(T)
        writetable(T,outname);