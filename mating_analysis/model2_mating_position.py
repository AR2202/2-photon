import sys
sys.path.append("/Users/annika/Documents/git_repos/2-photon/mating_analysis")
import mating_angles_learn_model2
from mating_angles_learn_model2 import learning_pipeline,apply_pretrained,prepare_training_data,evalulate_pretrained

#paths to data - change if model is to be trained/applied on new data
path_to_training='/Volumes/LaCie/Projects/Matthew/behaviour/R1_G10Ctrl3_Chamber3DLC_resnet50_Model3Apr24shuffle1_300000.csv' 
path_to_labels='/Volumes/LaCie/Projects/Matthew/behaviour/Ch3_chamber3.csv'  
path_to_training2_csv='/Volumes/LaCie/Projects/Matthew/behaviour/R1_Exp2_Chamber1DLC_resnet50_Model3Apr24shuffle1_300000.csv' 
path_to_labels2='/Volumes/LaCie/Projects/Matthew/behaviour/Exp2_chamber1.csv'  
path_to_training3_csv='/Volumes/LaCie/Projects/Matthew/behaviour/R1_DC1_Chamber4DLC_resnet50_Model3Apr24shuffle1_200000.csv' 
path_to_labels3='/Volumes/LaCie/Projects/Matthew/behaviour/DC1_chamber4.csv'  

#test data
path_to_test_labels='/Volumes/LaCie/Projects/Matthew/behaviour/Exp4_chamber1.csv'  
path_to_test_csv='/Volumes/LaCie/Projects/Matthew/behaviour/R1_Exp4_Chamber1DLC_resnet50_Model3Apr24shuffle1_200000.csv' 
path_to_test_labels2='/Volumes/LaCie/Projects/Matthew/behaviour/GC3_chamber5.csv'  
path_to_test_csv2='/Volumes/LaCie/Projects/Matthew/behaviour/R1_GC3_Chamber5DLC_resnet50_Model3Apr24shuffle1_200000.csv'  

#lists of all training data and paths
paths_to_training=[path_to_training,path_to_training2_csv,path_to_training3_csv]
paths_to_labels=[path_to_labels,path_to_labels2,path_to_labels3]
#lists of all test data and paths
paths_to_test=[path_to_test_csv,path_to_test_csv2]
paths_to_test_labels=[path_to_test_labels,path_to_test_labels2]
#data to apply the model on
path_to_data1='/Volumes/LaCie/Projects/Matthew/behaviour/R1_Exp2_Chamber1DLC_resnet50_Model3Apr24shuffle1_300000.csv' 
path_to_data2='/Volumes/LaCie/Projects/Matthew/behaviour/R1_G10Ctrl3_Chamber3DLC_resnet50_Model3Apr24shuffle1_300000.csv' 

features=["angles_b_scaled","head_dist_scaled","abd_dist_scaled","tilting_index_scaled"]
#training the model
models=learning_pipeline(paths_to_training,paths_to_labels,featurelist=features)  
#applying the pretrained model 
#if model is not to be trained again, the pretrained model can be loaded from the file with load_pretrained()
data1=prepare_training_data(path_to_data1,copstartframe=562,featurelist=features)
data2=prepare_training_data(path_to_data2,copstartframe=1936,featurelist=features)
predictions_data1,fraction1=apply_pretrained(models,data1,startframe=562) 
predictions_data2,fraction2=apply_pretrained(models,data2,startframe=1936) 
print("Fraction of abnormal copulation in group 1: {:.2f}".format(fraction1))
print("Fraction of abnormal copulation in group 2: {:.2f}".format(fraction2))

#model evaluation
print("Evaluating model on new data...")
scores=evalulate_pretrained(paths_to_test,paths_to_test_labels,featurelist=features)


