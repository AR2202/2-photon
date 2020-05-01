import numpy as np
import math
import sys
#this path needs to be updated for your machine
sys.path.append("/Users/annika/Documents/git_repos/2-photon/plotting")
import mating_angles_model2
from mating_angles_model2 import filtered_outputs,unfiltered_outputs,tilting_index
import mating_angles_labelled
from mating_angles_labelled import mating_angles_labelled
#paths to data - enter your paths here

path_to_data1='/Volumes/LaCie/Projects/Matthew/behaviour/R1_Exp2_Chamber1DLC_resnet50_Model3Apr24shuffle1_300000.csv' 
path_to_data2='/Volumes/LaCie/Projects/Matthew/behaviour/R1_G10Ctrl3_Chamber3DLC_resnet50_Model3Apr24shuffle1_300000.csv' 
#comment out these paths if you don't have labels

path_to_control_labels='/Volumes/LaCie/Projects/Matthew/behaviour/Ch3_chamber3.csv'  
path_to_exp_labels='/Volumes/LaCie/Projects/Matthew/behaviour/Exp2_chamber1.csv'  
#calculating mating angles
cutoff=16 #cutoff value for normal angle: 75 percentile of control

copulationstart1=562
#angles
angles_b,wing_dist_male,abd_dist,head_dist=unfiltered_outputs(path_to_data1)
angles_cop=180*angles_b[copulationstart1:]/math.pi

median1=np.median(angles_cop)/math.pi
percentile25_1=np.percentile(angles_cop,25)
percentile75_1=np.percentile(angles_cop,75)
#above cutoff
above_cutoff=100*len(angles_cop[angles_cop>cutoff])/len(angles_cop)
#tilting
tilting1=tilting_index(wing_dist_male,copulationstart1)
median1tilting=np.median(tilting1)
percentileTilting25_1=np.percentile(tilting1,25)
percentileTilting75_1=np.percentile(tilting1,75)

copulationstart2=1936
#angles
angles_b2,wing_dist_male2,abd_dist2,head_dist2=unfiltered_outputs(path_to_data2)
angles_cop2=180*angles_b2[copulationstart2:]/math.pi
median2=np.median(angles_cop2)
percentile25_2=np.percentile(angles_cop2,25)
percentile75_2=np.percentile(angles_cop2,75)
#above cutoff
above_cutoff2=100*len(angles_cop2[angles_cop2>cutoff])/len(angles_cop2)
#tilting
tilting2=tilting_index(wing_dist_male2,copulationstart2)
median2tilting=np.median(tilting2)
percentileTilting25_2=np.percentile(tilting2,25)
percentileTilting75_2=np.percentile(tilting2,75)
print("median mating angle and tilting index in group 1: {:.0f}({:.0f}-{:.0f}),{:.2f}({:.2f},{:.2f})"
.format(median1,percentile25_1,percentile75_1,median1tilting,percentileTilting25_1,percentileTilting75_1))
print("median mating angle and tilting index in group 2: {:.0f}({:.0f}-{:.0f}),{:.2f}({:.2f},{:.2f})"
.format(median2,percentile25_2,percentile75_2,median2tilting,percentileTilting25_2,percentileTilting75_2))
print("percentage of large mating angles above {} deg in group1: {:.0f}".format(cutoff,above_cutoff))
print("percentage of large mating angles above {} deg in group2: {:.0f}".format(cutoff,above_cutoff2))
#calculating mating angles of labelled data
#comment out this whole section if you don't have labelled data
angles_pos2,angles_neg2=mating_angles_labelled(path_to_data2,path_to_control_labels)
median_pos2=180*np.median(angles_pos2)/math.pi
median_neg2=180*np.median(angles_neg2)/math.pi
print("median mating angle for abnormal in group 2: {:.0f}".format(median_pos2))
print("median mating angle for normal in group 2: {:.0f}".format(median_neg2))
angles_pos,angles_neg=mating_angles_labelled(path_to_data1,path_to_exp_labels)
median_pos=180*np.median(angles_pos)/math.pi
median_neg=180*np.median(angles_neg)/math.pi
print("median mating angle for abnormal in group 1: {:.0f}".format(median_pos))
print("median mating angle for normal in group 1: {:.0f}".format(median_neg))