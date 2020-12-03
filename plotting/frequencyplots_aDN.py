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



def frequencies(filelist):
    print (filelist)
    freq = [re.search(r'\d+Hz', filename).group(0) for filename in filelist]
    freq_np=np.array(freq)
    uniquefreq=np.unique(freq_np)
    freq2=list(uniquefreq)
    freq2.sort(key=lambda x: int(re.search(r"\d+", x).group(0)))
    # sort by the frequency in ascending order - the number is extracted from the string and converted to int
    return freq2


def pulselengths(filelist):
    pulselength = [re.search(r'\d+ms', filename).group(0) for filename in filelist]
    pulse_np = np.array(pulselength)
    uniquepulse = np.unique(pulse_np)
    pulse2 = list(uniquepulse)
    pulse2.sort(key=lambda x: int(re.search(r"\d+", x).group(0)))
    # sort by the pulselength in ascending order - the number is extracted from the string and converted to int
    return pulse2


def freqPlot(pathname='',
             numpulses=4,
             pulsetimes=[20,40,60,80],
             pulsedur=5,
             expname='result'):
    print("this is the start")
    currentdir = os.getcwd()
    if pathname:

        print(pathname)
        print(pathname[0])
        if pathname[0] == '/':
            fullpath = pathname
        else:
            fullpath = os.path.join(currentdir, pathname)
    else:
        fullpath = currentdir
    print(fullpath)
    filelist = os.listdir(fullpath)
    
    if pulsedur <1:

        pulsedurstring = str(int(1000 * pulsedur))+'ms'
    else:
        pulsedurstring = str(pulsedur)+'s'

    med_figname = expname + '_male_medial.eps'
    lat_figname = expname + '_male_lateral.eps'
    med_figname_f = expname + '_female_medial.eps'
    lat_figname_f = expname + '_female_lateral.eps'
    med_figname_mf = expname + '_matedfemale_medial.eps'
    lat_figname_mf = expname + '_matedfemale_lateral.eps'

    malefiles = [filename for filename in filelist if '_male' in filename
               and '.mat' in filename
               and pulsedurstring in filename
               and 'ms' in filename and '_Hz' not in filename]
 
    malefiles_med = [filename for filename in malefiles if 'medial' in filename]

    malefiles_lat = [filename for filename in malefiles if 'lateral' in filename]

    femalefiles = [filename for filename in filelist if '_female' in filename
                   and '.mat' in filename
                   and pulsedurstring in filename
                   and 'ms' in filename and '_Hz' not in filename]
    femalefiles_med = [filename for filename in femalefiles if 'medial' in filename]

    femalefiles_lat = [filename for filename in femalefiles if 'lateral' in filename]
    
    matedfemalefiles = [filename for filename in filelist if '_matedFemale' in filename
                        and '.mat' in filename
                        and pulsedurstring in filename
                        and 'ms' in filename and '_Hz' not in filename]
    matedfemalefiles_med = [filename for filename in matedfemalefiles if 'medial' in filename]
    
    matedfemalefiles_lat = [filename for filename in matedfemalefiles if 'lateral' in filename]

    framerate = 5.92

    filelists = [malefiles_med,malefiles_lat,femalefiles_med,femalefiles_lat,matedfemalefiles_med,matedfemalefiles_lat]
    fignames = [med_figname,lat_figname,med_figname_f,lat_figname_f,med_figname_mf,lat_figname_mf]
    for filelist, figname in zip (filelists,fignames):
        freqs = frequencies(filelist)
        pulsel = pulselengths(filelist)
        numlines = len(freqs)
        numrows = len(pulsel)
        outputname = os.path.join(fullpath, figname)
        print(outputname)
        plotnumber = 1
        linenumber = 1
        for f in freqs:
            sublist = [filename for filename in filelist if f in filename]
            for p in pulsel:
                filename = [filen for filen in sublist if p in filen]
                print(filename)
                fullfile = os.path.join(fullpath, filename[0])
                data = scipy.io.loadmat(fullfile, matlab_compatible=True)
                mean = [dat for dat in data["mean_dff"][0]]
                mean_np = np.array(mean)
                n = int(data["n_files"][0][0])
                SEM = [dat for dat in data["SEM_dff"][0]]
                med_plus_SEM = [m+S for m, S in zip(mean, SEM)]
                med_minus_SEM = [m-S for m, S in zip(mean, SEM)]
                x = [n/framerate for n in range(len(mean))]
                ax = plt.subplot(numlines, numrows, plotnumber)
                ax.axis('off')
                plt.text(30, -0.3, ("n = "+str(n)))
                ax.set_ylim([-0.5, 0.3])
                if f == freqs[0]:
                    ax.set_title(p)
                currentAxis = plt.gca()
                for xval in pulsetimes:
                    currentAxis.add_patch(patches.Rectangle((xval, -0.2),
                                                            pulsedur,
                                                            0.5,
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
            plt.text(0.02,
                     (0.95-float(linenumber)*0.77/float(numlines)),
                     f,
                     fontsize=12,
                     transform=plt.gcf().transFigure)
            linenumber += 1
        bar = AnchoredSizeBar(ax.transData,
                              10,
                              '10 s',
                              7,
                              frameon=False,
                              size_vertical=0.01)
        ax.add_artist(bar)
        bar_vert = AnchoredSizeBar(ax.transData,
                                   1,
                                   '',
                                   1,
                                   frameon=False,
                                   size_vertical=0.2)
        ax.add_artist(bar_vert)
        plt.savefig(outputname)
        plt.close()
    return
