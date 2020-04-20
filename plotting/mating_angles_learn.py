import numpy as np
import osimport re
import sklearn
import sklearn.preprocessing
import pandas as pd
import mating_angles
from mating_angles import filtered_outputs, unfiltered_outputs,load_csv_file,tilting_index
from sklearn.linear_model import SGDClassifier

def scale_angles(angles):
    angles_matrix=angles.values.reshape(-1,1)
    scaled=sklearn.preprocessing.MinMaxScaler()
    scaled_angles=scaled.fit_transform(angles_matrix) 
    return(scaled_angles)

def scale_filtered(path,P):
    """loads the csv file of deeplabcut data
    specified as the path argument and determines mating angle
    from both wing and body axis data;
    returns the angles based on wing data and the angles based on body axis
    (in this order);
    scales the data
    This is the function that should be used if you want filtering of data by 
    those with a likelihood > P"""
    angles_w,angles_b,wing_dist_male,wing_dist_female,abd_dist=filtered_outputs(path,P)
    angles_w_scaled=scale_angles(angles_w)
    angles_b_scaled=scale_angles(angles_b)
    wing_dist_male_scaled=scale_angles(wing_dist_male)
    wing_dist_female_scaled=scale_angles(wing_dist_female)
    abd_dist_scaled=scale_angles(abd_dist)
    return angles_w_scaled,angles_b_scaled,wing_dist_male_scaled,wing_dist_female_scaled,abd_dist_scaled

def scale_unfiltered(path):
    """loads the csv file of deeplabcut data
    specified as the path argument and determines mating angle
    from both wing and body axis data;
    returns the angles based on wing data and the angles based on body axis
    (in this order);
    scales the data
    This is the function that should be used if you don't want filtering of data """
    angles_w,angles_b,wing_dist_male,wing_dist_female,abd_dist,copulationP=unfiltered_outputs(path)
    angles_w_scaled=scale_angles(angles_w)
    angles_b_scaled=scale_angles(angles_b)
    wing_dist_male_scaled=scale_angles(wing_dist_male)
    wing_dist_female_scaled=scale_angles(wing_dist_female)
    abd_dist_scaled=scale_angles(abd_dist)
    copulationP_scaled=scale_angles(copulationP)
    
    return angles_w_scaled,angles_b_scaled,wing_dist_male_scaled,wing_dist_female_scaled,abd_dist_scaled,copulationP_scaled

def train_SGD(X,y,loss="log"):
    X_train, X_test, y_train, y_test = sklearn.model_selection.train_test_split(X, y)
    n=X_train.shape[0]
    max_iter = np.ceil(10**6 / n)
    clf = SGDClassifier(loss=loss, max_iter=max_iter,early_stopping=True).fit(X_train, y_train)
    return clf

def prepare_training_data(path, filtering=False,P=0.8,featurelist=["angles_w_scaled","angles_b_scaled","wing_dist_male_scaled","wing_dist_female_scaled","abd_dist_scaled","copulationP_scaled"]):
    """loads csv file and scales the features, then makes an np.array of the features and returns the array"""
    X=np.array([])
    if filtering:
       angles_w_scaled,angles_b_scaled,wing_dist_male_scaled,wing_dist_female_scaled,abd_dist_scaled = scale_filtered(path,P)
    else:
       angles_w_scaled,angles_b_scaled,wing_dist_male_scaled,wing_dist_female_scaled,abd_dist_scaled,copulationP_scaled = scale_unfiltered(path)
    
    for feature in featurelist:
        if X.size>0:
            X=np.append(X,eval(feature),axis=1)
        else:
            X=eval(feature)
   
    return X

def import_train_test(path_to_csv,path_to_images,positives):
    """prepares training dataset"""
    """if positives is a list of framenumbers, the first frame should be 1"""
    X = prepare_training_data(path_to_csv)
    num = [int(re.search('\d+',filename).group(0)) for filename in os.listdir(path_to_images)]  
    num_shifted=[numb-1 for numb in num] 
    X_training=X(num_shifted)
    y_training=[0 for i in num_shifted]   
    positives_shifted=[pos-1 for pos in positives]
    y_training[positives_shifted]=1
    return X_training,y_training
