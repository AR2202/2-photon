import optogenetic_plot
from optogenetic_plot import optoPlot
import kruskal_mann_whitney_U
from kruskal_mann_whitney_U import KMWU

pathname =\
     "/Volumes/LaCie/Projects/aDN/imaging/GH146_chrimson_aDN_GCaMP6f/Results/"
labels = ["matedFemale"]
genders = ["_matedFemale_NonRetinal"]
identifiers = [".mat", "10ms", "40Hz", "0uMPTX"]
neuronparts = ["medial", "lateral"]
barylim = [-32, 220]
ylim = [-0.1, 0.5]
barcols = ["#ff4cff", "#cc00cc", "#00cc00"]

optoPlot(genders=genders,
         labels=labels,
         pathname=pathname,
         identifiers=identifiers,
         neuronparts=neuronparts,
         barylim=barylim,
         barcols=barcols,
         ylim=ylim,
         figuresize=(3, 4),
         expname='mean_non_retinal.eps')

print("Stats:")
print("5s pulse:")

KMWU(pathname=pathname,
     genders=genders,
     compareOn="neuronparts",
     pulsedurs=[5],
     identifiers=identifiers,
     neuronparts=neuronparts)
