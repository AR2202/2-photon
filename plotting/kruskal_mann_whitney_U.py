import scipy
import pandas as pd
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
from statsmodels.stats.multicomp import (MultiComparison)



def KMWU(pathname='',
         pulsedurs=[5],
         genders=["_male", "_female", "_matedFemale"],
         neuronparts=["medial", "lateral"],
         identifiers=[".mat", "10ms", "40Hz"],
         key="pulsedff",
         compareOn="genders",
         multicompmethod='holm'):
    '''performs a Kruskal-wallis test followed by multiple comparisons with mann-whitney-U-test'''

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

        if compareOn == "genders":
            for npart in range(len(neuronparts)):
                neuronpart = neuronparts[npart]
                print(neuronpart)
                groupnum = npart*len(genders)
                numgenders = len(genders)
                data = tuple(pulsedffs[groupnum:(groupnum+numgenders)])
                df = pd.DataFrame(pulsedffs[groupnum:(groupnum+numgenders)])
                df.rename(index={0:"female", 1:'matedFemale', 2:'male'})
                statsk = scipy.stats.kruskal(*data)
                print(statsk)

                stacked_data = df.stack().reset_index()
                stacked_data.rename(index={0:"female", 1:'matedFemale', 2:'male'})

                stacked_data = stacked_data.rename(columns={'level_0': 'genotype',
                                                    0:'result'})

                MultiComp = MultiComparison(stacked_data['result'],
                                    stacked_data['genotype'])
                print(MultiComp.allpairtest(scipy.stats.ranksums, method='Holm'))

        elif compareOn == "neuronparts":
            for gend in range(len(genders)):

                ind = [(numnpart*len(genders)+gend) for numnpart in range(len(neuronparts))]
                data = tuple([pulsedffs[index]for index in ind])
                df = pd.DataFrame([pulsedffs[index] for index in ind])
                statsk = scipy.stats.kruskal(*data)
                print(statsk)

                stacked_data = df.stack().reset_index()
                stacked_data.rename(index={0:"medial",1:'lateral'})

                stacked_data = stacked_data.rename(columns={'level_0': 'neuronpart',
                                                            0:'result'})

                MultiComp = MultiComparison(stacked_data['result'],
                                            stacked_data['neuronpart'])
                print(MultiComp.allpairtest(scipy.stats.ranksums, method='Holm'))

        else:
            print("not a valid selection for compareOn - must be \"genders\" or \"neuronparts\"")
