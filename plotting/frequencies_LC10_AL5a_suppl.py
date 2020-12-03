import numpy as np
import optogenetic_plot_f
from optogenetic_plot_f import optoPlotf


pathname = "/Volumes/LaCie/Projects/aDN/imaging/LC10_Chrimson_AL5a_GCaMP6f/Results/"

labels = ["10", "20", "40", "80"]
genders = ["_male"]
neuronparts = ["10Hz", "20Hz", "40Hz", "80Hz"]
identifiers1 = [".mat", "10ms", "AOTu_", "0uMPTX"]
identifiers2 = [".mat", "10ms", "AOTu_", "0uMPTX"]
identifiers3 = [".mat", "10ms", "AOTu_", "0uMPTX"]

optoPlotf(genders=genders,
          labels=labels,
          pathname=pathname,
          neuronparts=neuronparts,
          ylim=[-0.1, 2.2],
          barylim=[-50, 1505],
          pulsedur=5,
          expname='freq_5s.eps',
          allonerow=True,
          identifiers=identifiers1,
          ytickrange=np.arange(0, 1505, step=500))

optoPlotf(genders=genders,
          labels=labels,
          pathname=pathname,
          neuronparts=neuronparts,
          ylim=[-0.1, 2.2],
          barylim=[-50, 1505],
          pulsedur=1,
          expname='freq_1s.eps',
          allonerow=True,
          identifiers=identifiers2,
          ytickrange=np.arange(0, 1505, step=500))

optoPlotf(genders=genders,
          labels=labels,
          pathname=pathname,
          neuronparts=neuronparts,
          ylim=[-0.1, 2.2],
          barylim=[-50, 1505],
          pulsedur=0.2,
          expname='freq_200ms.eps',
          allonerow=True,
          identifiers=identifiers3,
          ytickrange=np.arange(0, 1505, step=500))
