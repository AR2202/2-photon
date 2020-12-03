import optogenetic_plot
from optogenetic_plot import optoPlot
import mann_whitney_U
from mann_whitney_U import MWU
pathname =\
    "/Volumes/LaCie/Projects/aDN/imaging/ppk23-lexA_aDN-GCaMP6f/Results/"
labels = ["female"]
genders = ["_female"]
neuronparts = ["medial", "lateral"]


optoPlot(genders=genders, labels=labels, pathname=pathname,
         neuronparts=neuronparts, ylim=[-0.1, 1],
         barylim=[0, 30], pulsedur=5,
         expname='mean_pulse_5s.eps')

print("Stats:")

print("5s suppl figure:")
MWU(pathname=pathname, genders=genders, neuronparts=neuronparts,
    compareOn="genders", pulsedurs=[5])