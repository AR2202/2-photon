import optogenetic_plot_p
from optogenetic_plot_p import optoPlotp


pathname =\
    "/Volumes/LaCie/Projects/aDN/imaging/LC10_lexA_aDN_GCaMP6f_GABA_inhibitors/15min_incubation/Results/"
labels = ["8ms", "10ms","12ms", "20ms"]
genders = ["_male_fly"]
neuronparts = ["8ms", "10ms", "12ms", "20ms"]
identifiers1 = [".mat", "40Hz","medial", "s0uMPTX"]
identifiers2 = [".mat", "40Hz","lateral", "s0uMPTX"]

optoPlotp(genders=genders,
          labels=labels,
          pathname=pathname,
          neuronparts=neuronparts,
          ylim=[-0.1, 2.2],
          barylim=[0, 230],
          pulsedur=5,
          expname='pulselength_5s_medial.eps',
          allonerow=True,
          identifiers=identifiers1)



optoPlotp(genders=genders,
          labels=labels,
          pathname=pathname,
          neuronparts=neuronparts,
          ylim=[-0.1, 2.2],
          barylim=[0, 230],
          pulsedur=5,
          expname='pulselength_5s_lateral.eps',
          allonerow=True,
          identifiers=identifiers2)


