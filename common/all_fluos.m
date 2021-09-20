files = dir('*tif');
fluos = cell(numel(files), 1);
dffs = cell(numel(files), 1);

resultsdir = '../../../Results_2020';
Timestable = readtable('../../../2020/times.txt', 'Format', '%s%f');
outputfile = fullfile(resultsdir, 'LC10_male_f_dff.mat');
stimfiles = dir('../../../2020/data');


for f = 1:numel(files)
    filename = files(f).name;
    for n = 1:size(stimfiles, 1)
        if contains(stimfiles(n).name, filename(1:12))
            stimname = stimfiles(n).name;
        end
    end


    for i = 1:height(Timestable)
        if contains(filename, Timestable.Var1{i})
            time = Timestable.Var2(i);
        end
    end
    outputfig = fullfile(resultsdir, (strcat(stimname, '.eps')));
    fluo = extract_fluo(filename);
    numframes = size(fluo, 2);
    framerate = numframes / time;
    frames = [1:numframes];
    x = frames ./ framerate;
    fluos{f} = fluo;
    dff = calculate_dff(fluo, 5, 15);
    dffs{f} = dff;
    fignew = figure('Name', stimname, 'Units', 'centimeters', 'Position', [10, 10, 15, 5]);
    h = plot(x, dff, 'k');
    xlim([0, x(numframes)]);
    ylim([-1, 1]);

    xlabel('seconds');
    ylabel('\DeltaF/F');
    ax = gca;
    ax.FontSize = 13;
    ax.LineWidth = 2;
    saveas(fignew, outputfig, 'epsc');
    close(fignew);

end
save(outputfile, 'dffs', 'fluos');