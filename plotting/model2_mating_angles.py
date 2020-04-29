import numpy as np
import math
import sys
sys.path.append("/Users/annika/Documents/git_repos/2-photon/plotting")
import mating_angles_model2
from mating_angles_model2 import filtered_outputs,unfiltered_outputs,tilting_index
#paths to data -

path_to_data1='/Volumes/LaCie/Projects/Matthew/behaviour/R1_Exp2_Chamber1DLC_resnet50_Model3Apr24shuffle1_300000.csv' 
path_to_data2='/Volumes/LaCie/Projects/Matthew/behaviour/R1_G10Ctrl3_Chamber3DLC_resnet50_Model3Apr24shuffle1_300000.csv' 






angles_b,wing_dist_male,abd_dist,head_dist=unfiltered_outputs(path_to_data1)
median1=180*np.median(angles_b)/math.pi
tilting1=tilting_index(wing_dist_male,562)
median1tilting=np.median(tilting1)

angles_b2,wing_dist_male2,abd_dist2,head_dist2=unfiltered_outputs(path_to_data2)
median2=180*np.median(angles_b2)/math.pi
tilting2=tilting_index(wing_dist_male2,1936)
median2tilting=np.median(tilting2)
print("median mating angle and tilting index in group 1: {},{}".format(median1,median1tilting))
print("median mating angle and tilting index in group 2: {},{}".format(median2,median2tilting))