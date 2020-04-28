import numpy as np
import os
import re
import sklearn
import sklearn.preprocessing
import pandas as pd
import matplotlib.pyplot as plt
import mating_angles
from mating_angles import filtered_outputs, unfiltered_outputs,load_csv_file,tilting_index,tilting_index_all_frames
from sklearn.linear_model import SGDClassifier,RidgeCV
from sklearn.neighbors import KNeighborsClassifier
from sklearn.feature_selection import SelectFromModel
from sklearn.ensemble import RandomForestClassifier 
from sklearn.pipeline import Pipeline
from sklearn.svm  import SVC, LinearSVC
from sklearn.feature_selection import SelectPercentile, chi2
from sklearn.model_selection import cross_val_score,GridSearchCV,train_test_split
from sklearn.preprocessing import StandardScaler,MinMaxScaler
from sklearn.naive_bayes import GaussianNB
from sklearn.ensemble import BaggingClassifier
from joblib import dump,load

#Feature scaling

def scale_angles(angles):
    angles_matrix=angles.values.reshape(-1,1)
    scaled=sklearn.preprocessing.MinMaxScaler()
    standardized=StandardScaler()
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

def scale_unfiltered(path,copstartframe=500):
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
    tilting_index_scaled=scale_angles(tilting_index_all_frames(wing_dist_male,wing_dist_female,copstartframe))
    
    return angles_w_scaled,angles_b_scaled,wing_dist_male_scaled,wing_dist_female_scaled,abd_dist_scaled,copulationP_scaled,tilting_index_scaled

#Classification models

def train_SGD(X,y,loss="log"):
    X_train, X_test, y_train, y_test = sklearn.model_selection.train_test_split(X, y)
    n=X_train.shape[0]
    max_iter = np.ceil(10**6 / n)
    parameters = {
    'sgd__alpha': (0.00001, 0.000001),
    'sgd__penalty': ('l2', 'elasticnet'),
    # 'sdg__max_iter': (10, 50, 80),
}
    pipe = Pipeline([('anova', SelectPercentile(chi2)),
                ('sgd', SGDClassifier(loss=loss, max_iter=max_iter,early_stopping=True))])
    
    grid_search = GridSearchCV(pipe, parameters, verbose=1)
    clf = grid_search.fit(X_train, y_train)
    CVScore=grid_search.best_score_
    testScore=clf.score(X_test,y_test)
    return clf,testScore,CVScore

def train_knn(X,y):
    X_train, X_test, y_train, y_test = sklearn.model_selection.train_test_split(X, y)
    parameters = {'knc__n_neighbors': [1, 2, 3,4,5],
                'knc__weights': ['uniform','distance']}
    pipe = Pipeline([('feature_selection', SelectFromModel(LinearSVC())),
                    ('knc', KNeighborsClassifier())])
    grid_search = GridSearchCV(pipe, parameters, verbose=1)
    knn =grid_search.fit(X_train,y_train) 
    CVScore=grid_search.best_score_ 
    testScore=knn.score(X_test,y_test)
    return knn,testScore,CVScore

def train_SVC(X,y):
    X_train, X_test, y_train, y_test = sklearn.model_selection.train_test_split(X, y)
    param_grid = [
  {'svc__C': [1, 10, 100, 1000], 'svc__kernel': ['linear']},
  {'svc__C': [1, 10, 100, 1000], 'svc__gamma': [0.001, 0.0001], 'svc__kernel': ['rbf']},
 ]
    pipe = Pipeline([('anova', SelectPercentile(chi2)),
                ('svc', SVC(probability=True))])
    grid_search = GridSearchCV(pipe, param_grid, verbose=1)           
    supportV =grid_search.fit(X_train,y_train)  
    CVScore=grid_search.best_score_
    testScore=supportV.score(X_test,y_test)
    return supportV,testScore,CVScore

def train_NB(X,y):
    X_train, X_test, y_train, y_test = sklearn.model_selection.train_test_split(X, y)
    pipe = Pipeline([('feature_selection', SelectFromModel(LinearSVC())),
                    ('classification', GaussianNB())])
    NB =pipe.fit(X_train,y_train)  
    testScore=NB.score(X_test,y_test)
    return NB,testScore

def train_randomForest(X,y):
    X_train, X_test, y_train, y_test = sklearn.model_selection.train_test_split(X, y)
    parameters = {'rfc__n_estimators': [10, 25, 50,75,100,125]}
    pipe = Pipeline([('feature_selection', SelectFromModel(LinearSVC())),
                    ('rfc', RandomForestClassifier())])
    grid_search = GridSearchCV(pipe, parameters, verbose=1)
    randomF =grid_search.fit(X_train,y_train) 
    CVScore=grid_search.best_score_ 
    testScore=randomF.score(X_test,y_test)
    return randomF,testScore, CVScore

def prepare_training_data(path, filtering=False,P=0.8,copstartframe=500,
featurelist=["angles_w_scaled","angles_b_scaled","abd_dist_scaled","tilting_index_scaled"]):
    """loads csv file and scales the features, then makes an np.array of the features and returns the array"""
    X=np.array([])
    if filtering:
       angles_w_scaled,angles_b_scaled,wing_dist_male_scaled,wing_dist_female_scaled,abd_dist_scaled = scale_filtered(path,P)
    else:
       angles_w_scaled,angles_b_scaled,wing_dist_male_scaled,wing_dist_female_scaled,abd_dist_scaled,copulationP_scaled,tilting_index_scaled = scale_unfiltered(path,copstartframe=copstartframe)
    #tilting_index=tilting_index_all_frames(wing_dist_male_scaled,wing_dist_female_scaled,copstartframe)
    for feature in featurelist:
        if X.size>0:
            X=np.append(X,eval(feature),axis=1)
        else:
            X=eval(feature)
   
    return X

def import_train_test(path_to_csv,path_to_images,positives,filtering=False,P=0.8,copstartframe=500,
featurelist=["angles_w_scaled","angles_b_scaled","tilting_index_scaled","abd_dist_scaled","copulationP_scaled"]):
    """prepares training dataset"""
    """if positives is a list of framenumbers, the first frame should be 1"""
    X = prepare_training_data(path_to_csv,filtering=filtering,P=P,featurelist=featurelist,copstartframe=copstartframe)
    num = [int(re.search('\d+',filename).group(0)) for filename in os.listdir(path_to_images)]  
    num_shifted=[numb-1 for numb in num] 
    X_training=X[num_shifted]
    y_training=[0 for i in num_shifted]   
    positives_shifted=[pos-1 for pos in positives]
    for pos in positives_shifted:
        y_training[pos]=1
    return X_training,y_training

def import_train_test_from_csv(path_to_csv,path_to_labels,filtering=False,P=0.8,
featurelist=["angles_w_scaled","angles_b_scaled","tilting_index_scaled","abd_dist_scaled"]):
    """prepares training dataset"""
    """if positives is a list of framenumbers, the first frame should be 1"""
    labeltable=pd.read_csv(path_to_labels,header=0)
    copstartframe=int(labeltable[labeltable.keys()[0]][0])
    nums_neg=[]
    nums_pos=[]
    X = prepare_training_data(path_to_csv,filtering=filtering,P=P,featurelist=featurelist,copstartframe=copstartframe)
    for i in range(0,len(labeltable[labeltable.keys()[1]]),2): 
        nums_neg=nums_neg+list(range(labeltable[labeltable.keys()[1]][i],labeltable[labeltable.keys()[1]][i+1])) 
    for i in range(0,len(labeltable[labeltable.keys()[2]]),2): 
        nums_pos=nums_pos+list(range(labeltable[labeltable.keys()[2]][i],labeltable[labeltable.keys()[2]][i+1]))
    nums=nums_neg+nums_pos 
    y_neg=np.zeros(len(nums_neg),int)
    y_pos=np.ones(len(nums_pos),int)
    X_training=X[nums]
    y_training=np.concatenate([y_neg,y_pos])   
    return X_training,y_training,copstartframe

def learning_pipeline(path_to_csv,path_to_images,positives=[],training_only=False,filtering_data=False,
filtering_train=False,P=0.8, copstartframe =500, training_from_csv=True,
featurelist=["angles_w_scaled","angles_b_scaled","abd_dist_scaled","tilting_index_scaled"]):
    """pipeline for machine learning"""
    if training_from_csv:
        X,y,copstartframe=import_train_test_from_csv(path_to_csv,path_to_images,filtering=filtering_train,P=P,featurelist=featurelist)
    else:
        X,y=import_train_test(path_to_csv,path_to_images,positives,filtering=filtering_train,P=P,featurelist=featurelist,copstartframe=copstartframe)
    data=prepare_training_data(path_to_csv, filtering=filtering_data,P=P,featurelist=featurelist,copstartframe=copstartframe)
    logReg,logRegScore,logRegCVScore=train_SGD(X,y,loss="log")
    print("Logistic Regression Test Score: {}".format(logRegScore))
    print("Logistic Regression CV Score: {}".format(logRegCVScore))
    suppVC,SVCScore,SVCCVScore=train_SVC(X,y)
    print("Support Vector Machine Test Score: {}".format(SVCScore))
    print("Support Vector Machine CV Score: {}".format(SVCCVScore))
    knn,knnScore,knnCVScore=train_knn(X,y)
    print("K Nearest Neighbors Test Score: {}".format(knnScore))
    print("K Nearest Neighbors CV Score: {}".format(knnCVScore))
    randomF,randomFScore,randomFCVScore=train_randomForest(X,y)
    print("Random Forest Test Score: {}".format(randomFScore))
    print("Random Forest CV Score: {}".format(randomFCVScore))
    NB,NBScore=train_NB(X,y)
    print("Naive Bayes Test Score: {}".format(NBScore))

    if training_only:
        models={"LogReg":{"model":logReg,"score":logRegScore,"CVScore":logRegCVScore},
            "SVC":{"model": suppVC,"score":SVCScore,"CVScore":SVCCVScore},
            "KNN":{"model":knn,"score":knnScore,"CVScore":knnCVScore},
            "RFC":{"model": randomF,"score":randomFScore,"CVScore":randomFCVScore},
            "NB":{"model":NB,"score":NBScore}}
    else:
        predictionsLogReg=logReg.predict_proba(data)
        predictionsSVC=suppVC.predict_proba(data)
        predictionsKnn=knn.predict_proba(data)
        predictionsRandomF=randomF.predict_proba(data)
        predictionsNB=NB.predict_proba(data)
        #creating predictions by averaging the predicted class probabilities from each model
        ensembePredictions=(predictionsLogReg+predictionsSVC+predictionsKnn+predictionsRandomF+predictionsNB)/5
        classPredictions=np.apply_along_axis(np.argmax,1,ensembePredictions)
        #plt.plot(predictionsLogReg,predictionsSVC,predictionsKnn,predictionsRandomF,predictionsNB,ensembePredictions)
        #plt.show()
        models={"LogReg":{"model":logReg,"score":logRegScore,"CVScore":logRegCVScore,"predictions":predictionsLogReg},
                "SVC":{"model": suppVC,"score":SVCScore,"CVScore":SVCCVScore,"predictions":predictionsSVC},
                "KNN":{"model":knn,"score":knnScore,"CVScore":knnCVScore,"predictions":predictionsKnn},
                "RFC":{"model": randomF,"score":randomFScore,"CVScore":randomFCVScore,"predictions":predictionsRandomF},
                "NB":{"model":NB,"score":NBScore,"predictions":predictionsNB},
                "ensemble":{"predictions":ensembePredictions,"classPredictions":classPredictions}}
    dump(models, 'trained_models.joblib') 
    return models

def load_pretrained(filename='trained_models.joblib'):
    """reload the pretrained model"""
    models=load(filename)
    return models

def apply_pretrained(models,data,startframe=0):
    """apply the pretrained model to new data"""
    #load models
    logReg=models["LogReg"]["model"]
    suppVC=models["SVC"]["model"]
    knn=models["KNN"]["model"]
    randomF=models["RFC"]["model"]
    NB=models["NB"]["model"]
    #predict data
    predictionsLogReg=logReg.predict_proba(data)
    predictionsSVC=suppVC.predict_proba(data)
    predictionsKnn=knn.predict_proba(data)
    predictionsRandomF=randomF.predict_proba(data)
    predictionsNB=NB.predict_proba(data)
    ensembePredictions=(predictionsLogReg+predictionsSVC+predictionsKnn+predictionsRandomF+predictionsNB)/5
    classPredictions=np.apply_along_axis(np.argmax,1,ensembePredictions)
    classPredictions=classPredictions[startframe:]
    fraction_positives=len(classPredictions[classPredictions==1])/len(classPredictions)
    return classPredictions,fraction_positives

#Regression Models

def train_RidgeRegressor(X,y):
    X_train, X_test, y_train, y_test = train_test_split(X, y)
    ridge = RidgeCV()
    reg = ridge.fit(X_train, y_train)
    testScore=reg.score(X_test,y_test)
    y_predicted=reg.predict(X_test)
    plt.figure()
    plt.scatter(y_test,y_predicted)
    plt.show()
    return reg,testScore

#prepare training data

def coords_to_1D(df_x,df_y):
    return (600*df_y+df_x)

def prepare_features(headX,headY,abdomenX,abdomenY,wing1X,wing1Y,wing2X,wing2Y):
    head=scale_angles(coords_to_1D(headX,headY))
    abdomen=scale_angles(coords_to_1D(abdomenX,abdomenY))
    wing1=scale_angles(coords_to_1D(wing1X,wing1Y))
    wing2=scale_angles(coords_to_1D(wing2X,wing2Y))
    features=[head,abdomen,wing1,wing2]
    return features

def prepare_male_female_features(path):
    data=load_csv_file(path)
    malefeatures=prepare_features(data.MaleHeadX,data.MaleHeadY,
                                data.MaleAbdomenX,data.MaleAbdomenY,
                                data.MaleWing1X,data.MaleWing1Y, 
                                data.MaleWing2X,data.MaleWing2Y)

    femalefeatures=prepare_features(data.FemaleHeadX,data.FemaleHeadY,
                                data.CopulationX,data.CopulationY,
                                data.FemaleWing1X,data.FemaleWing1Y, 
                                data.FemaleWing2X,data.FemaleWing2Y)
    return malefeatures, femalefeatures

def prepare_regression_training_features(path,label=1):
    """label: the index of the feature that is used as a label for training purposes;
    corresponds to the index of features in prepare_features()
    0:head
    1:abdomen
    2:wing1
    3:wing2
    """
    malefeatures, femalefeatures=prepare_male_female_features(path)
    labelMale=malefeatures[label]
    del malefeatures[label]
    malefeat=np.concatenate(malefeatures,axis=1)
    labelFemale=femalefeatures[label]
    del femalefeatures[label]
    femalefeat=np.concatenate(femalefeatures,axis=1)
    return malefeat,labelMale,femalefeat,labelFemale

def train_regression_models(path,label=1):
    """label: the index of the feature that is used as a label for training purposes;
    corresponds to the index of features in prepare_features()
    0:head
    1:abdomen
    2:wing1
    3:wing2
    """
    Xm,ym,Xf,yf = prepare_regression_training_features(path,label=label)
    maleRidge,maleRidgeScore=train_RidgeRegressor(Xm,ym)
    femaleRidge,femaleRidgeScore=train_RidgeRegressor(Xf,yf)
    print("male Ridge Regression Score: {}".format(maleRidgeScore))
    print("female Ridge Regression Score: {}".format(femaleRidgeScore))
    



