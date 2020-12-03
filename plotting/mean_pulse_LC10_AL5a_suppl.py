import optogenetic_plot
from optogenetic_plot import optoPlot
import mann_whitney_U
from mann_whitney_U import MWU

pathname =\
    "/Volumes/LaCie/Projects/aDN/imaging/LC10_Chrimson_AL5a_GCaMP6f/Results/"
labels = ["female", "male", "female no r", "male no r"]
genders = ["_female", "_male"]
neuronparts = ["AOTu_", "AOTuNoRetinal"]

optoPlot(genders=genders, labels=labels, pathname=pathname, 
         neuronparts=neuronparts, ylim=[-0.1, 2.2],
         barylim=[0, 230], pulsedur=5,
         expname='mean_pulse_5s.eps', allonerow=True)

optoPlot(genders=genders, labels=labels, pathname=pathname,
         neuronparts=neuronparts, ylim=[-0.1, 2.2],
         barylim=[0, 230], pulsedur=1,
         expname='mean_pulse_1s.eps', allonerow=True)

optoPlot(genders=genders, labels=labels, pathname=pathname,
         neuronparts=neuronparts, ylim=[-0.1, 2.2],
         barylim=[0, 230], pulsedur=0.2,
         expname='mean_pulse_200ms.eps', allonerow=True)

print("Stats:")
print("1s pulse for mainsuppl figure:")

MWU(pathname=pathname, genders=genders, neuronparts=neuronparts,
    compareOn="genders", pulsedurs=[1])

print("5s and 200ms pulse for suppl figure:")

MWU(pathname=pathname, genders=genders, neuronparts=neuronparts,
    compareOn="neuronparts", pulsedurs=[5, 0.2])
