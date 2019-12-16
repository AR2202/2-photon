files=dir('*tif');
fluos=cell(numel(files),1);
dffs=cell(numel(files),1);
x=[1:800];
resultsdir='../../imaging_Sheffield/Results';
outputfile=fullfile(resultsdir,'f_dff.mat');
for f =1:numel(files)
filename=files(f).name;
outputfig=fullfile(resultsdir,(strrep(filename,'.tif','.eps')));
fluo = extract_fluo(filename);
fluos{f}= fluo;
dff = calculate_dff(fluo,5,15);
dffs{f}=dff;
fignew=figure('Name',filename,'Units','centimeters','Position',[10 10 15 5]);
h=plot(dff,'k');
                                                xlim([0,800]);
                        ylim([-1,1]);
                        
                        xlabel('frames');
                        ylabel ('\DeltaF/F');
                        ax = gca;
                        ax.FontSize = 13;
                        ax.LineWidth=2;
                        saveas(fignew,outputfig,'epsc');
                        close(fignew);

end
save(outputfile,'dffs','fluos');