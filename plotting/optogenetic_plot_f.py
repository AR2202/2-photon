import scipy
import matplotlib.pyplot as plt    
from scipy import io
import matplotlib.patches as patches
import os
import math
from mpl_toolkits.axes_grid1.anchored_artists import AnchoredSizeBar
import matplotlib.patches as patches
import re
import numpy as np
import seaborn as sb
import itertools




def optoPlotf(pathname='',
              pulsedur=5,
              expname='mean_pulse.eps',
              genders=["_male", "_female", "_matedFemale"],
              labels=["male", "female", "mated female"],
              neuronparts=["medial", "lateral_d"],
              identifiers=[".mat", "10ms", "40Hz"],
              ylim=[-0.2, 0.3],
              barylim=[0, 30],
              allonerow=False,
              barcols=['m', 'g'],
              frequencies=[10, 20, 40, 80],
              ytickrange=np.arange(0, 250, step=50),
              figuresize=(6, 1.2)
              ):

    currentdir = os.getcwd()
    if pathname:
        if pathname[0]=='/':
            fullpath = pathname
        else:
            fullpath = os.path.join(currentdir,pathname)
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
                      and all([identifier in filename for identifier in identifiers])]
            nfiles = [filename for filename in gfiles if n in filename]

            if nfiles:
                filelists.append(nfiles)

    framerate = 5.92
    if allonerow:
        ncolumns = len(genders) * len(neuronparts)+1

        nrows = 1
    else:

        ncolumns = len(genders)+1
        nrows = len(neuronparts)
    pulsedffs = np.zeros((len(genders)+len(neuronparts), 2))
    plotnumber = 1
    expnumber = 1
    plot = plt.figure(figsize=figuresize)
    for filelist in filelists:
        print(filelist)
        fullfile = os.path.join(fullpath, filelist[0])
        data = scipy.io.loadmat(fullfile, matlab_compatible=True)
        mean = [dat for dat in data["mean_pulseav_dff"][0]]
        n = int(data["n_files"][0][0])
        SEM = [dat for dat in data["SEM_pulseav_dff"][0]]
        med_plus_SEM = [m+S for m,S in zip(mean, SEM)]
        med_minus_SEM = [m-S for m,S in zip(mean, SEM)]
        x = [f/framerate for f in range(len(mean))]
        pulsedff = [dat[0] for dat in data["pulsedff"]]
        mean_pulsedff = 100*np.mean(pulsedff)
        SEM_pulsedff = 100*np.std(pulsedff)/math.sqrt(n)
        pulsedffs[(expnumber-1), 0] = mean_pulsedff
        pulsedffs[(expnumber-1), 1] = SEM_pulsedff
        ax = plot.add_subplot(nrows, ncolumns, plotnumber)
        ax.axis('off')
        ax.set_ylim(ylim)
        ax.add_patch(patches.Rectangle((10,
                                        ylim[0]),
                                       pulsedur,
                                       0.01,
                                       linewidth=0,
                                       facecolor='#DC143C',
                                       alpha=0.5,
                                       zorder=1))        
        ax.fill_between(x,
                        med_minus_SEM,
                        med_plus_SEM,
                        linewidth=0,
                        color='#d2d2d2',
                        zorder=2)

        ax.plot(x,
                mean,
                color='#545454',
                linewidth=0.3,
                zorder=3)
        if plotnumber == ncolumns * (nrows - 1) + ncolumns - 1:
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
        colors = list(itertools.chain.from_iterable(itertools.repeat(c, int(numbars / 2)) for c in barcols))
        plotnumber += 1
        if plotnumber % ncolumns == 0:
            ax = plot.add_subplot(nrows, ncolumns, plotnumber)
            for axis in ["top", "right"]:
                ax.spines[axis].set_visible(False)
            ax.set_ylim(barylim)
            ax.set_xlim([0, 90])
            ax.set_xticks([0, 10, 20, 30, 40, 50, 60, 70, 80])
            ax.set_yticks(ytickrange)
            ax.errorbar(frequencies,
                        [pulsedffs[expnumber-i][0]for i in reversed(range(1,ncolumns))],
                        [pulsedffs[expnumber-i][1]for i in reversed(range(1,ncolumns))],
                        marker='o',
                        ls='',
                        color='k')
            plotnumber += 1
        expnumber += 1
    outputname = os.path.join(pathname, expname)
    plot.savefig(outputname)
    plt.close()

    return
