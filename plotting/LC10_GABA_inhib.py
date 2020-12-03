import optogenetic_plot_all_pulses
from optogenetic_plot_all_pulses import opto_plot_all

pathname =\
    "/Volumes/LaCie/Projects/aDN/imaging/LC10_lexA_aDN_GCaMP6f_GABA_inhibitors/15min_incubation/Results/"
labels = ["male output sites", "male input sites","female output sites", "female input sites"]
genders = ["_male", "matedFemale"]
neuronparts = ["medial", "lateral_deep"]
identifiers1 = [".mat", "40Hz", "10ms"]
pulsetimes = [19.5946, 39.6959, 59.6284, 79.7297]
barcols = ["#ff4cff","#cc00cc","#00cc00","#4cff4c"]

opto_plot_all(genders=genders,
              labels=labels,
              pathname=pathname,
              neuronparts=neuronparts,
              ylim=[-0.1, 0.3],
              barylim=[0,50],
              pulsedur=5,
              expname='mean_pulse_5s.eps',
              allonerow=True,
              identifiers=identifiers1,
              pulsetimes=pulsetimes,
              barcols=barcols)
