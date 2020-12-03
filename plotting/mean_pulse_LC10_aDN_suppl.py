import optogenetic_plot
from optogenetic_plot import optoPlot
import mann_whitney_U
import mann_whitney_U_multicomp
from mann_whitney_U_multicomp import MWU_multi

pathname =\
    "/Volumes/LaCie/Projects/aDN/imaging/LC10_lexA_aDN_GCaMP6f_GABA_inhibitors/15min_incubation/Results/"
labels = ["female", "mated female", "male", "male retinal -"]
genders = ["_female", "matedFemale", "_male_fly", "_male_nonRetinal"]
labels2 = ["male retinal -"]
conc = ["s0uMPTX","s150uMPTX", "s300uMPTX" ]
neuronparts = ["medial", "lateral"]
ylim = [-0.1, 0.5]
barylim = [-2, 50]
barcols = ["#ff4cff", "#cc00cc", "#00cc00", "#66ff66"]
barcols2 = ["#66ff66"]
identifiers0 = [".mat", "10ms", "40Hz", "s0uMPTX"]
identifiers150 = [".mat", "10ms", "40Hz", "150uMPTX"]
identifiers300 = [".mat", "10ms", "40Hz", "s300uMPTX"]
identifiersstats = [".mat", "10ms", "40Hz", "_male_nonRetinal"]


optoPlot(genders=genders,
         labels=labels,
         pathname=pathname,
         identifiers=identifiers0,
         neuronparts=neuronparts,
         ylim=ylim,
         barylim=barylim,
         barcols=barcols,
         expname='mean_pulse_5s_0uMPTX_with_nonRetinal.eps')


optoPlot(genders=genders,
         labels=labels,
         pathname=pathname,
         neuronparts=neuronparts,
         barylim=[-2,   50],
         ylim=ylim,
         barcols=barcols2,
         expname='mean_pulse_5s_150uMPTX_nonRetinal.eps',
         identifiers=identifiers150)


optoPlot(genders=genders,
         labels=labels,
         pathname=pathname,
         neuronparts=neuronparts,
         barylim=[-20, 50],
         ylim=ylim,
         barcols=barcols2,
         expname='mean_pulse_5s_300uMPTX_nonRetinal.eps',
         identifiers=identifiers300)

print("Stats non Retinal medial:")

_ = MWU_multi(genders=conc,
              neuronparts=neuronparts,
              identifiers=identifiersstats,
              pathname=pathname,
              pulsedurs=[5],
              comparisons=[(0, 1), (0, 2), (1, 2)]
              )
print("Stats non Retinal lateral:")

_ = MWU_multi(genders=conc,
              neuronparts=neuronparts,
              identifiers=identifiersstats,
              pathname=pathname,
              pulsedurs=[5],
              comparisons=[(3, 4), (3, 5), (4, 5)]
              )
