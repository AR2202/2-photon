import numpy as np
import optogenetic_plot_p
from optogenetic_plot_p import optoPlotp


pathname = "/Volumes/LaCie/Projects/aDN/imaging/LC10_Chrimson_AL5a_GCaMP6f/Results/"
labels = ["8", "10", "12", "20"]
genders = ["_male"]
neuronparts = ["8ms", "10ms", "12ms", "20ms"]
identifiers1 = [".mat", "40Hz", "AOTu_", "0uMPTX"]
pulsedurs = [8, 10, 12, 20]

optoPlotp(genders=genders,
          labels=labels,
          pathname=pathname,
          neuronparts=neuronparts,
          ylim=[-0.1, 2.2],
          barylim=[-50, 1505],
          pulsedur=5,
          expname='pulselength_5s.eps',
          allonerow=True,
          identifiers=identifiers1,
          pulsedurs=pulsedurs,
          ytickrange=np.arange(0, 1500, step=500))

optoPlotp(genders=genders,
          labels=labels,
          pathname=pathname,
          neuronparts=neuronparts,
          ylim=[-0.1, 2.2],
          barylim=[-50, 1505],
          pulsedur=0.2,
          expname='pulselength_200ms.eps',
          allonerow=True,
          identifiers=identifiers1,
          pulsedurs=pulsedurs,
          ytickrange=np.arange(0, 1500, step=500))
