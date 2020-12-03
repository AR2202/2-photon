import frequencyplots
   
from frequencyplots import freqPlot
def freqPlot(pathname='',numpulses=4,pulsetimes=[20,40,60,80],pulsedur=5,expname='result'):

        
matpath1 = '/Volumes/LaCie/automated_tracking_outputs/to_analyse/Megan/MaleTNT1_mean_facingangle1freame'
matpath2 = '/Volumes/LaCie/automated_tracking_outputs/to_analyse/Megan/MaleTNT2_mean_facingangle1frame'
matpath3 = '/Volumes/LaCie/automated_tracking_outputs/to_analyse/Megan/MaleTNT3_mean_facingangle1frame'
matpath4 = '/Volumes/LaCie/automated_tracking_outputs/to_analyse/Megan/MaleTNT4_mean_facingangle1frame'



matpaths = [matpath1,matpath2,matpath3,matpath4]


colors = [['#378CCB','#256390'],['#74AFDB','#4B98D0'],['#C9DFF2','#B5D2ED'],['#DEEBF7','#A0C6E8']]

figurepath = '/Volumes/LaCie/automated_tracking_outputs/to_analyse/Megan/TNT1to4_mean_facingangle1frame.eps'

pdfplot_from_paths(matpaths,colors,figurepath)
