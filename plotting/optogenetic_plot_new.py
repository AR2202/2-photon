import scipy
import matplotlib.pyplot as plt
from scipy import io
import matplotlib.patches as patches
import os
import math
from mpl_toolkits.axes_grid1.anchored_artists import AnchoredSizeBar
import numpy as np


def optoPlot(pathname='',
             pulsedur=5,
             expname='mean_pulse.eps',
             genders=["_male", "_female", "_matedFemale"],
             labels=["male", "female", "mated female"],
             neuronparts=["medial", "lateral_d"],
             identifiers=[".mat", "10ms", "40Hz"],
             exclude=[],
             ylim=[-0.2, 0.3],
             barylim=[0, 30],
             allonerow=False,
             barcols=['m', 'g'],
             ytickrange=np.arange(0, 250, step=50),
             figuresize=(6, 1.2)):
    '''makes a plot of the calcium traces with stimulation times indicated and
    a bar graph of the mean deltaF/F'''
    currentdir = os.getcwd()
    if pathname:
        # if pathname is given
        # if pathname is the absolute path, starting with /
        # use this pathname unmodified
        # otherwise if it's a relative path, append it to the current path
        if pathname[0] == '/':
            fullpath = pathname
        else:
            fullpath = os.path.join(currentdir, pathname)
    else:
        fullpath = currentdir
    # else if pathname is not given, take the current path

    filelist = os.listdir(fullpath)
    # make the pulsedurstring
    # the pulsedurstring should be in ms if pulsedur is below 1
    # otherwise in s
    if pulsedur < 1:

        pulsedurstring = str(int(1000 * pulsedur)) + 'ms'
    else:
        pulsedurstring = str(pulsedur) + 's'

    filelists = []
    # go through the list of neuronparts and geners and find the right file
    # append it to the filelist
    for n in neuronparts:
        for g in genders:
            gfiles = [filename for filename in filelist
                      if g in filename and pulsedurstring in filename
                      and all([identifier in filename
                               for identifier in identifiers])
                      and all([excluder not in filename
                               for excluder in exclude])
                      ]

            nfiles = [filename for filename in gfiles if n in filename]

            if nfiles:
                filelists.append(nfiles)

    framerate = 5.92
    # if allonerow was set to True, make only one row of plots
    # otherwise make a row for each neuronpart
    if allonerow:
        ncolumns = len(genders) * len(neuronparts) + 1

        nrows = 1
    else:

        ncolumns = len(genders)+1
        nrows = len(neuronparts)
    # inititalize the pulsedffs array to all zeros
    pulsedffs = np.zeros((len(genders)*len(neuronparts), 2))
    plotnumber = 1
    expnumber = 1
    plot = plt.figure(figsize=figuresize)
    # go through the filelists
    for filelist in filelists:
        print("filelist:")
        print(filelist)
        fullfile = os.path.join(fullpath, filelist[0])
        print("filename:")
        print(fullfile)
        data = scipy.io.loadmat(fullfile, matlab_compatible=True)
        mean = [dat for dat in data["mean_pulseav_dff"][0]]
        n = int(data["n_flies"][0][0])
        print("n={}".format(n))
        SEM = [dat for dat in data["SEM_pulseav_dff"][0]]
        med_plus_SEM = [m+S for m, S in zip(mean, SEM)]
        med_minus_SEM = [m-S for m, S in zip(mean, SEM)]
        x = [f/framerate for f in range(len(mean))]
        pulsedff = [dat[0] for dat in data["pulsedff"]]
        mean_pulsedff = 100*np.mean(pulsedff)
        SEM_pulsedff = 100*np.std(pulsedff)/math.sqrt(n)
        pulsedffs[(expnumber-1), 0] = mean_pulsedff
        pulsedffs[(expnumber-1), 1] = SEM_pulsedff
        ax = plot.add_subplot(nrows, ncolumns, plotnumber)
        ax.axis('off')
        ax.set_ylim(ylim)
        # plot a patch indicating the pulse
        ax.add_patch(patches.Rectangle((10,
                                        ylim[0]),
                                       pulsedur,
                                       0.01,
                                       linewidth=0,
                                       facecolor='#DC143C',
                                       alpha=0.5,
                                       zorder=1))
        # plot a shaded area for the SEM
        ax.fill_between(x,
                        med_minus_SEM,
                        med_plus_SEM,
                        linewidth=0,
                        color='#d2d2d2',
                        zorder=2)
        # plot a line for the mean
        ax.plot(x,
                mean,
                color='#545454',
                linewidth=0.3,
                zorder=3)
        # add the scalebar to the last plot of calcium traces
        if plotnumber == ncolumns * (nrows-1) + ncolumns - 1:
            bar = AnchoredSizeBar(ax.transData,
                                  10,
                                  '10 s',
                                  'lower right',
                                  borderpad=2,
                                  frameon=False,
                                  size_vertical=0.005,
                                  color='#545454')
            ax.add_artist(bar)
            bar_vert = AnchoredSizeBar(ax.transData,
                                       0.2,
                                       '$\Delta$F/F',
                                       'upper right',
                                       borderpad=0.1,
                                       frameon=False,
                                       size_vertical=0.2,
                                       color='#545454')
            ax.add_artist(bar_vert)
        plotnumber += 1
        # if it is the last plot in the row
        # make the bar plot
        if plotnumber % ncolumns == 0:
            ax = plot.add_subplot(nrows, ncolumns, plotnumber)
            ax.set_xticks([])
            ax.set_yticks(ytickrange)

            ax.tick_params(axis='y',
                           length=1,
                           color='#545454',
                           width=0.3,
                           labelsize=6,
                           pad=0.2,
                           labelcolor='#545454')
            for axis in ["bottom", "top", "right"]:
                ax.spines[axis].set_visible(False)
                ax.set_ylim(barylim)
            ax.bar(labels,
                   [pulsedffs[expnumber-i][0]
                       for i in reversed(range(1, ncolumns))],
                   yerr=[pulsedffs[expnumber-i][1]
                         for i in reversed(range(1, ncolumns))],
                   width=(figuresize[0]/40),
                   linewidth=0,
                   ecolor='#545454',
                   error_kw={"elinewidth": 0.5},
                   color=barcols)

            plotnumber += 1
        expnumber += 1
    # save the plot
    outputname = os.path.join(pathname, expname)
    plot.savefig(outputname)
    plt.close()
    return
