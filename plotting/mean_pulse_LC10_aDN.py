import optogenetic_plot
from optogenetic_plot import optoPlot
import kruskal_mann_whitney_U
from kruskal_mann_whitney_U import KMWU

pathname =\
    "/Volumes/LaCie/Projects/aDN/imaging/LC10_lexA_aDN_GCaMP6f_GABA_inhibitors/15min_incubation/Results/"

labels = ["female", "mated female", "male"]
genders = ["_female", "matedFemale", "_male_fly"]
neuronparts = ["medial", "lateral"]
ylim = [-0.1, 0.5]
barylim = [-2, 250]
barcols = ["#ff4cff", "#cc00cc", "#00cc00"]
identifiers0 = [".mat", "10ms", "40Hz", "s0uMPTX"]
identifiers150 = [".mat", "10ms", "40Hz", "150uMPTX"]
identifiers300 = [".mat", "10ms", "40Hz", "300uMPTX"]


optoPlot(genders=genders,
         labels=labels,
         pathname=pathname,
         identifiers=identifiers0,
         neuronparts=neuronparts,
         ylim=ylim,
         barylim=barylim,
         barcols=barcols,
         expname='mean_pulse_5s_0uMPTX.eps')

print("Stats:")

print("0uM PTX:")
KMWU(pathname=pathname, genders=genders, neuronparts=neuronparts,
     compareOn="genders", pulsedurs=[5], identifiers=identifiers0)

optoPlot(genders=genders, labels=labels, pathname=pathname,
         neuronparts=neuronparts, ylim=[-0.1, 0.5],
         barylim=[-2, 250],
         pulsedur=5,
         barcols=barcols,
         expname='mean_pulse_5s_150uMPTX.eps',
         identifiers=identifiers150)

print("Stats:")

print("150 uM PTX:")
KMWU(pathname=pathname, genders=genders, neuronparts=neuronparts,
     compareOn="genders", pulsedurs=[5], identifiers=identifiers150)

optoPlot(genders=genders, labels=labels, pathname=pathname,
         neuronparts=neuronparts, ylim=[-0.1, 0.5],
         barylim=[-32, 220],
         pulsedur=5,
         barcols=barcols,
         expname='mean_pulse_5s_300uMPTX.eps',
         identifiers=identifiers300)

print("Stats:")

print("300 uM PTX:")
KMWU(pathname=pathname, genders=genders, neuronparts=neuronparts,
     compareOn="genders", pulsedurs=[5], identifiers=identifiers300)
