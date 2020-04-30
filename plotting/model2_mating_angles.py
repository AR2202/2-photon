import numpy as np
import math
import sys
sys.path.append("/Users/annika/Documents/git_repos/2-photon/plotting")
import mating_angles_model2
from mating_angles_model2 import filtered_outputs,unfiltered_outputs,tilting_index
import mating_angles_labelled
from mating_angles_labelled import mating_angles_labelled
#paths to data -

path_to_data1='/Volumes/LaCie/Projects/Matthew/behaviour/R1_Exp2_Chamber1DLC_resnet50_Model3Apr24shuffle1_300000.csv' 
path_to_data2='/Volumes/LaCie/Projects/Matthew/behaviour/R1_G10Ctrl3_Chamber3DLC_resnet50_Model3Apr24shuffle1_300000.csv' 
path_to_control_labels='/Volumes/LaCie/Projects/Matthew/behaviour/Ch3_chamber3.csv'  
path_to_exp_labels='/Volumes/LaCie/Projects/Matthew/behaviour/Exp2_chamber1.csv'  
#calculating mating angles
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
#calculating mating angles of labelled data
angles_pos2,angles_neg2=mating_angles_labelled(path_to_data2,path_to_control_labels)
median_pos2=180*np.median(angles_pos2)/math.pi
median_neg2=180*np.median(angles_neg2)/math.pi
print("median mating angle for abnormal in group 2: {}".format(median_pos2))
print("median mating angle for normal in group 2: {}".format(median_neg2))
angles_pos,angles_neg=mating_angles_labelled(path_to_data1,path_to_exp_labels)
median_pos=180*np.median(angles_pos)/math.pi
median_neg=180*np.median(angles_neg)/math.pi
print("median mating angle for abnormal in group 1: {}".format(median_pos))
print("median mating angle for normal in group 1: {}".format(median_neg))