import scipy
from scipy import io
import os
import numpy as np
import statsmodels.stats.multitest as multi


def MWU_multi(pathname='',
              pulsedurs=[5],
              genders=["_male", "_female"],
              neuronparts=["medial", "lateral"],
              comparisons=[(0, 1), (2, 3), (0, 2), (1, 3)],
              identifiers=[".mat", "10ms", "40Hz"],
              key="pulsedff",
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
        genderneuronparts = []

        for n in neuronparts:
            for g in genders:
                genderneuronpart = g+n
                genderneuronparts.append(genderneuronpart)
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
        for (g1, g2) in comparisons:
            gender1 = genderneuronparts[g1]
            gender2 = genderneuronparts[g2]
            data1 = pulsedffs[g1]
            data2 = pulsedffs[g2]
            stat, p = scipy.stats.mannwhitneyu(data1, data2, use_continuity=True, alternative=None)
            print("Mann-Whitney-U between {} and {}:".format(gender1, gender2))
            print(p)
            ps.append(p)
            comparison = gender1 + " vs. " + gender2
            compares.append(comparison)
    reject, ps_adjusted, _, _ = multi.multipletests(ps, method=multicompmethod)
    for comp, rej, p_ in zip(compares, reject, ps_adjusted):

        print("H0 for {} can be rejected: {}, p = {:.2f} ".format(comp, rej, p_))
    print("Adjusted p values using method {}: {}".format(multicompmethod, ps_adjusted))
    return ps_adjusted
