from scipy.stats import ks_2samp
from plot_touch import logDecorator
import plot_touch
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
import statsmodels.stats.multitest as multi
import sys
sys.path.append(
    '/Users/annika/Documents/git_repos/matlab_scripts/python_scripts')


def MWU(pathname='',
        pulsedurs=[5],
        genders=["_male", "_female", "_matedFemale"],
        neuronparts=["medial", "lateral"],
        identifiers=[".mat", "10ms", "40Hz"],
        key="pulsedff",
        compareOn="genders",
        multicompmethod='holm'):
    currentdir = os.getcwd()
    if pathname:
        if pathname[0] == '/':
            fullpath = pathname
        else:
            fullpath = os.path.join(currentdir, pathname)
    else:
        fullpath = currentdir

    dirlist = os.listdir(fullpath)
    ps = []
    for pulsedur in pulsedurs:
        if pulsedur < 1:

            pulsedurstring = str(int(1000 * pulsedur))+'ms'
        else:
            pulsedurstring = str(int(pulsedur))+'s'

        filelists = []

        for n in neuronparts:
            for g in genders:
                gfiles = [filename for filename in dirlist
                          if g in filename and pulsedurstring in filename
                          and all([identifier in filename
                                   for identifier in identifiers])]
                nfiles = [filename for filename in gfiles if n in filename]
                if nfiles:
                    filelists.append(nfiles)

        pulsedffs = []

        for filelist in filelists:

            fullfile = os.path.join(fullpath, filelist[0])
            data = scipy.io.loadmat(fullfile, matlab_compatible=True)
            pulsedff = [dat[0] for dat in data[key]]
            pulsedffs.append(pulsedff)
        # Mann-Whitney-U test

        compares = []
        if compareOn == "genders":
            for npart in range(len(neuronparts)):
                neuronpart = neuronparts[npart]
                groupnum = npart*len(genders)
                gender1 = genders[0]
                gender2 = genders[1]
                data = tuple(pulsedffs)
                statsk = scipy.stats.kruskal(*data)
                print(statsk)
                data1 = pulsedffs[groupnum]
                data2 = pulsedffs[groupnum+1]
                stat, p = scipy.stats.mannwhitneyu(
                    data1, data2, use_continuity=True, alternative=None)
                print(
                    "Mann-Whitney-U between {} and {} in {}:".format(gender1, gender2, neuronpart))
                print(p)
                ps.append(p)
                comparison = gender1 + " vs. " + gender2 + " in " + neuronpart
                compares.append(comparison)
        elif compareOn == "neuronparts":

            for gend in range(len(genders)):
                gender = genders[gend]
                neuronpart1 = neuronparts[0]
                neuronpart2 = neuronparts[1]
                data1 = pulsedffs[gend]
                data2 = pulsedffs[gend+len(genders)]
                stat, p = scipy.stats.mannwhitneyu(
                    data1, data2, use_continuity=True, alternative=None)
                print(
                    "Mann-Whitney-U between {} and {} in {}:".format(neuronpart1, neuronpart2, gender))
                print(p)
                ps.append(p)
                comparison = neuronpart1 + " vs. " + neuronpart2 + " in " + gender
                compares.append(comparison)
        else:
            print(
                "not a valid selection for compareOn - must be \"genders\" or \"neuronparts\"")
    reject, ps_adjusted, _, _ = multi.multipletests(ps, method=multicompmethod)
    for comp, rej, p_ in zip(compares, reject, ps_adjusted):

        print("H0 for {} can be rejected: {}, p = {:.2f} ".format(comp, rej, p_))
    print("Adjusted p values using method {}: {}".format(
        multicompmethod, ps_adjusted))
    return ps_adjusted


def ks_2groups(data1, data2):
    ks_statistic, p_value = ks_2samp(data1, data2)
    return p_value
