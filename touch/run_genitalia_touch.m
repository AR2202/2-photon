function run_genitalia_touch(varargin)
arguments=varargin;
CurrDir = (pwd);
 options = struct('foldername','imaging_preprocessed','framerate',5.92,'numberframes',500,'baseline_start',2,'baseline_end',11,'outputdir','Results','multiROI',false);
%call the options_resolver function to check optional key-value pair
%arguments
[options,~]=options_resolver(options,arguments,'run_genitalia_touch');
%setting the values for optional arguments
framerate = options.framerate;
numberframes = options.numberframes;
baseline_start = options.baseline_start;
baseline_end = options.baseline_end;
outputdirv=fullfile(CurrDir,options.outputdir);
multiROI=options.multiROI;
foldername=options.foldername;



cd(foldername);
dirs = dir();

for p = 1:numel(dirs)
    if ~dirs(p).isdir
      continue;
    end
    DIRname = dirs(p).name;
    disp(['Analysing folder: ' DIRname]);
    if ismember(DIRname,{'.','..'})
      continue;
    end 
     error_handling_wrapper('touch_errors.log',...
                            'genitalia_touch',...
                            DIRname,...
                            'framerate',framerate,...
                            'numberframes',numberframes,...
                            'baseline_start',baseline_start,...
                            'baseline_end',baseline_end,...
                            'outputdir',outputdirv,...
                            'multiROI',multiROI);
      
end
cd (CurrDir);