import pandas as pd
import numpy as np
import scipy
from scipy import io
import statsmodels.api as sm
import matplotlib.pyplot as plt
import seaborn as sb

file_A = "/Volumes/LaCie/automated_tracking_outputs/phototaxis/aDN/aDN_A_5min_phototaxis_PImeans_PI.mat"
file_B = "/Volumes/LaCie/automated_tracking_outputs/phototaxis/aDN/aDN_B_5min_phototaxis_PImeans_PI.mat"
file_C = "/Volumes/LaCie/automated_tracking_outputs/phototaxis/aDN/aDN_C_5min_phototaxis_PImeans_PI.mat"
file_D = "/Volumes/LaCie/automated_tracking_outputs/phototaxis/aDN/aDN_D_5min_phototaxis_PImeans_PI.mat"

dataA = scipy.io.loadmat(file_A, matlab_compatible=True)

PImeansA = dataA["PImeans"][0]
PIA = np.asarray([data[0] for data in dataA["PI"]])
print(PImeansA)
print(PIA)

dataB = scipy.io.loadmat(file_B, matlab_compatible=True)

PImeansB = dataB["PImeans"][0]
PIB = np.asarray([data[0] for data in dataB["PI"]])
print(PImeansB)
print(PIB)

dataC = scipy.io.loadmat(file_C, matlab_compatible=True)

PImeansC = dataC["PImeans"][0]
PIC = np.asarray([data[0] for data in dataC["PI"]])
print(PImeansC)
print(PIC)

dataD = scipy.io.loadmat(file_D, matlab_compatible=True)

PImeansD = dataD["PImeans"][0]
PID = np.asarray([data[0] for data in dataD["PI"]])
print(PImeansD)
print(PID)


groups = ["A","B","C","D"]

meansdata = [PImeansA, PImeansB, PImeansC, PImeansD]
indivdata = [PIA, PIB, PIC, PID]
colors = ["#748189", "#8797a0", "#9bacb7", "#5e77f9"]
sb.set_palette(sb.color_palette(colors))
f, axes = plt.subplots(1, 2)

ax1 = sb.boxplot(data=meansdata, ax=axes[0], width=0.5)
ax1.set(xlabel='', ylabel='light preference index')
ax1.set_xticklabels(groups)
ax2 = sb.boxplot(data=indivdata, ax=axes[1], width=0.5)
ax2.set(xlabel='', ylabel='light preference index')
ax2.set_xticklabels(groups)
plt.show()
