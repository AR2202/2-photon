import optogenetic_plot
from optogenetic_plot import optoPlot

pathname = "/Volumes/LaCie/Projects/aDN/imaging/LC10_Chrimson_AL5a_GCaMP6f/Results/"
labels = ["8","10","12","20"]
genders = ["_male"]
neuronparts = ["8ms","10ms","12ms","20ms"]
identifiers = [".mat","40Hz"]

optoPlot(genders=genders,
         labels=labels,
         pathname=pathname,
         neuronparts=neuronparts,
         ylim=[-0.1,2.2],
         barylim=[0,230],
         pulsedur=5,
         expname='pulselength_5s.eps',
         allonerow=True,
         identifiers=identifiers)

optoPlot(genders=genders,
         labels=labels,
         pathname=pathname,
         neuronparts=neuronparts,
         ylim=[-0.1,2.2],barylim=[0,230],
         pulsedur=1,
         expname='pulselength_1s.eps',
         allonerow=True,
         identifiers=identifiers)

optoPlot(genders=genders,
         labels=labels,
         pathname=pathname,
         neuronparts=neuronparts,
         ylim=[-0.1,2.2],
         barylim=[0,230],
         pulsedur=0.2,
         expname='pulselength_200ms.eps',
         allonerow=True,
         identifiers=identifiers)
