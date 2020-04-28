import mating_angles_learn
from mating_angles_learn import learning_pipeline,apply_pretrained,prepare_training_data

#paths to data - change if model is to be trained/applied on new data
path_to_training='/Volumes/LaCie/Projects/Matthew/behaviour/R1_Exp2_Chamber1_CompressEndDLC_resnet50_crf15_tstMar12shuffle1_300000filtered.csv' 
path_to_labels='/Volumes/LaCie/Projects/Matthew/behaviour/Exp2_chamber1.csv'  
path_to_data1='/Volumes/LaCie/Projects/Matthew/behaviour/R1_G10Ctrl3_Chamber3_CompressEndDLC_resnet50_crf15_tstMar12shuffle1_300000filtered.csv' 
path_to_data2='/Volumes/LaCie/Projects/Matthew/behaviour/R1_Exp2_Chamber1_CompressEndDLC_resnet50_crf15_tstMar12shuffle1_300000filtered.csv' 
#training the model
models=learning_pipeline(path_to_training,path_to_labels)  
#applying the pretrained model 
#if model is not to be trained again, the pretrained model can be loaded from the file with load_pretrained()
predictions_data1,fraction1=apply_pretrained(models,path_to_data1,startframe=1300) 
predictions_data2,fraction2=apply_pretrained(models,path_to_data2,startframe=562) 


