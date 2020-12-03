import scipy
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os
import math
from mpl_toolkits.axes_grid1.anchored_artists import AnchoredSizeBar
import matplotlib.patches as patches
import numpy as np
import itertools
import sys



def optoPlot_fst_lst(pathname='',
                     pulsedur=5,
                     expname='mean_pulse.eps',
                     genders=["_male", "_female", "_matedFemale"],
                     labels=["male", "female", "mated female"],
                     neuronparts=["medial", "lateral_d"],
                     identifiers=[".mat", "10ms", "40Hz"],
                     ylim=[-0.2, 0.3],
                     barylim=[0, 30],
                     allonerow=False,
                     barcols=['#EB008B', '#3FFF00']):
    currentdir = os.getcwd()
    if pathname:
        if pathname[0] == '/':
            fullpath = pathname
        else:
            fullpath = os.path.join(currentdir, pathname)
    else:
        fullpath = currentdir
    filelist = os.listdir(fullpath)
  
    if pulsedur < 1:

        pulsedurstring = str(int(1000 * pulsedur))+'ms'
    else:
        pulsedurstring = str(pulsedur)+'s'
    
    filelists = []
    for n in neuronparts:
        for g in genders:
            gfiles = [filename for filename in filelist
                      if g in filename and pulsedurstring in filename
                      and all([identifier in filename
                               for identifier in identifiers])]
            nfiles = [filename for filename in gfiles if n in filename]
           
            if nfiles:
                filelists.append(nfiles)

    framerate = 5.92
    if allonerow:
        ncolumns = len(genders) * len(neuronparts)+1
       
        nrows = 3
    else:

        ncolumns = len(genders)+1
        nrows = len(neuronparts)
    pulsedffs = np.zeros((len(genders)+len(neuronparts), 2))
    plotnumber = 1    
    expnumber = 1
    for filelist in filelists:
        # print(filelist)
        fullfile = os.path.join(fullpath, filelist[0])
        data = scipy.io.loadmat(fullfile, matlab_compatible=True)
        mean = [dat for dat in data["mean_pulseav_dff"][0]]
        n = int(data["n_files"][0][0])
        SEM = [dat for dat in data["SEM_pulseav_dff"][0]]
        meanFst = [dat for dat in data["mean_first_dff"][0]]
        SEMFst = [dat for dat in data["SEM_first_dff"][0]]
        meanLst = [dat for dat in data["mean_last_dff"][0]]
        SEMLst = [dat for dat in data["SEM_last_dff"][0]]
        med_plus_SEM =[m+S for m, S in zip(mean, SEM)]
        med_minus_SEM = [m-S for m, S in zip(mean, SEM)]
        med_plus_SEMF = [m+S for m, S in zip(meanFst, SEMFst)]
        med_minus_SEMF = [m-S for m, S in zip(meanFst, SEMFst)]
        med_plus_SEML = [m+S for m, S in zip(meanLst, SEMLst)]
        med_minus_SEML = [m-S for m, S in zip(meanLst, SEMLst)]
        x = [f/framerate for f in range(len(mean))]
        pulsedff = [dat[0] for dat in data["pulsedff"]]
        mean_pulsedff = 100*np.mean(pulsedff) 
        SEM_pulsedff = 100*np.std(pulsedff)/math.sqrt(n)
        pulsedffs[(expnumber-1), 0] = mean_pulsedff
        pulsedffs[(expnumber-1), 1] = SEM_pulsedff
        ax = plt.subplot(nrows, ncolumns, plotnumber)
        ax.axis('off')
        ax.set_ylim(ylim)
        ax.add_patch(patches.Rectangle((10, ylim[0]),
                                       pulsedur,
                                       ylim[1]-ylim[0],
                                       linewidth=0,
                                       facecolor='#EBBFBF',
                                       alpha=0.5,
                                       zorder=1))
        ax.fill_between(x,
                        med_minus_SEM,
                        med_plus_SEM,
                        color='lightgrey',
                        zorder=2)
        ax.plot(x,
                mean,
                color='#1A1A1A',
                linewidth=0.8,
                zorder=3)
        plotnumber += 1
        ax = plt.subplot(nrows,
                         ncolumns,
                         plotnumber)
        ax.axis('off')
        ax.set_ylim(ylim)
        ax.add_patch(patches.Rectangle((10,
                                        ylim[0]),
                                       pulsedur,
                                       ylim[1]-ylim[0],
                                       linewidth=0,
                                       facecolor='#EBBFBF',
                                       alpha=0.5,
                                       zorder=1))

        ax.fill_between(x,
                        med_minus_SEMF,
                        med_plus_SEMF,
                        color='lightgrey',
                        zorder=2)
        ax.plot(x,
                meanFst,
                color='#1A1A1A',
                linewidth=0.8,
                zorder=3)
        plotnumber += 1
        ax = plt.subplot(nrows,
                         ncolumns,
                         plotnumber)
        ax.axis('off')
        ax.set_ylim(ylim)
        ax.add_patch(patches.Rectangle((10, ylim[0]),
                                       pulsedur,
                                       ylim[1]-ylim[0],
                                       linewidth=0,
                                       facecolor='#EBBFBF',
                                       alpha=0.5,
                                       zorder=1))

        ax.fill_between(x,
                        med_minus_SEML,
                        med_plus_SEML,
                        color='lightgrey',
                        zorder=2)
        ax.plot(x,
                meanLst,
                color='#1A1A1A',
                linewidth=0.8,
                zorder=3)
        plotnumber += 1
        
        if plotnumber == ncolumns * (nrows-1)+ncolumns-1:
            bar = AnchoredSizeBar(ax.transData,
                                  10,
                                  '10 s',
                                  7,
                                  frameon=False,
                                  size_vertical=0.01)
            ax.add_artist(bar)
            bar_vert = AnchoredSizeBar(ax.transData,
                                       0.2,
                                       '',
                                       1,
                                       frameon=False,
                                       size_vertical=0.2)
            ax.add_artist(bar_vert)
        numbars = ncolumns-1
        colors = list(itertools.chain.from_iterable(
                                                    itertools.repeat(
                                                        c, int(numbars/2)
                                                        )
                                                    for c in barcols
                                                    )
                      )
        
        expnumber += 1
    outputname = os.path.join(pathname, expname)
    plt.savefig(outputname)
    plt.close()
    return
