import numpy as np
import optogenetic_plot
from optogenetic_plot import optoPlot
import kruskal_mann_whitney_U
from kruskal_mann_whitney_U import KMWU
import mann_whitney_U_multicomp
from mann_whitney_U_multicomp import MWU_multi

pathname = "/Volumes/LaCie/Projects/aDN/imaging/LC10_Chrimson_AL5a_GCaMP6f/Results/"
labels = ["female", "male"]
genders = ["_female", "_male"]
neuronparts = ["AOTu_", "AOTuNoRetinal"]
identifiers = ["0uMPTX", ".mat", "40Hz", "10ms"]


optoPlot(genders=genders,
         labels=labels,
         pathname=pathname,
         neuronparts=neuronparts,
         ylim=[-0.1, 2.4],
         barylim=[-2, 1500],
         pulsedur=5,
         expname='mean_pulse_5s.eps',
         identifiers=identifiers,
         ytickrange=np.arange(0, 1500, step=500)
         )


print("Stats 5s:")

_ = MWU_multi(genders=genders,
              neuronparts=neuronparts,
              identifiers=identifiers,
              pathname=pathname,
              pulsedurs=[5]
              )

optoPlot(genders=genders,
         labels=labels,
         pathname=pathname,
         neuronparts=neuronparts,
         ylim=[-0.1, 2.4],
         barylim=[-2, 500],
         pulsedur=1,
         expname='mean_pulse_1s.eps',
         identifiers=identifiers,
         ytickrange=np.arange(0, 500, step=100)
         )

print("Stats 1s:")
_ = MWU_multi(genders=genders,
              neuronparts=neuronparts,
              identifiers=identifiers,
              pathname=pathname,
              pulsedurs=[1]
              )
optoPlot(genders=genders,
         labels=labels,
         pathname=pathname,
         neuronparts=neuronparts,
         ylim=[-0.1, 2.4],
         barylim=[-2, 500],
         pulsedur=0.2,
         expname='mean_pulse_200ms.eps',
         identifiers=identifiers,
         ytickrange=np.arange(0, 500, step=100)
         )

print("Stats 200ms:")

_ = MWU_multi(genders=genders,
              neuronparts=neuronparts,
              identifiers=identifiers,
              pathname=pathname,
              pulsedurs=[0.2]
              )
