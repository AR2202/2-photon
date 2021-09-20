import optogenetic_plot_f
from optogenetic_plot_f import optoPlotf


pathname =\
    "/Volumes/LaCie/Projects/aDN/imaging/LC10_lexA_aDN_GCaMP6f_GABA_inhibitors/15min_incubation/Results/"

labels = ["4", "10", "20", "40", "80"]
genders = ["_male_fly"]
neuronparts = ["4Hz", "10Hz", "20Hz", "40Hz", "80Hz"]
identifiers1 = [".mat", "10ms", "medial", "s0uMPTX"]
identifiers2 = [".mat", "10ms", "lateral", "s0uMPTX"]


optoPlotf(genders=genders,
          labels=labels,
          pathname=pathname,
          neuronparts=neuronparts,
          ylim=[-0.1, 2.2],
          barylim=[0, 230],
          pulsedur=5,
          expname='freq_5s_medial.eps',
          allonerow=True,
          identifiers=identifiers1,
          frequencies=[4, 10, 20, 40, 80])

optoPlotf(genders=genders,
          labels=labels,
          pathname=pathname,
          neuronparts=neuronparts,
          ylim=[-0.1, 2.2],
          barylim=[0, 230],
          pulsedur=5,
          expname='freq_5s_lateral.eps',
          allonerow=True,
          identifiers=identifiers2,
          frequencies=[4, 10, 20, 40, 80])
