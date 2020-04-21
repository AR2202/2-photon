import numpy as np
import os
import re
import sklearn
import sklearn.preprocessing
import pandas as pd
import mating_angles
from mating_angles import filtered_outputs, unfiltered_outputs,load_csv_file,tilting_index
from sklearn.linear_model import SGDClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.feature_selection import SelectFromModel
from sklearn.ensemble import RandomForestClassifier 
from sklearn.pipeline import Pipeline
from sklearn.svm  import SVC, LinearSVC
from sklearn.feature_selection import SelectPercentile, chi2
from sklearn.model_selection import cross_val_score,GridSearchCV
from sklearn.preprocessing import StandardScaler,MinMaxScaler
from sklearn.naive_bayes import GaussianNB


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

def train_knn(X,y,neighbors=3):
    X_train, X_test, y_train, y_test = sklearn.model_selection.train_test_split(X, y)
    parameters = {'knc__n_neighbors': [1, 2, 3,4,5],
                'knc__weights': ['uniform','distance']}
    pipe = Pipeline([('feature_selection', SelectFromModel(LinearSVC())),
                    ('knc', KNeighborsClassifier(neighbors))])
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
                ('svc', SVC())])
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
    parameters = {'rfc__n_estimators': [10, 25, 50,75,100,125],
                'rfc__weights': ['uniform','distance']}
    pipe = Pipeline([('feature_selection', SelectFromModel(LinearSVC())),
                    ('rfc', RandomForestClassifier())])
    grid_search = GridSearchCV(pipe, parameters, verbose=1)
    randomF =grid_search.fit(X_train,y_train) 
    CVScore=grid_search.best_score_ 
    testScore=randomF.score(X_test,y_test)
    return randomF,testScore, CVScore

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

def import_train_test(path_to_csv,path_to_images,positives,filtering=False,P=0.8,featurelist=["angles_w_scaled","angles_b_scaled","wing_dist_male_scaled","wing_dist_female_scaled","abd_dist_scaled","copulationP_scaled"]):
    """prepares training dataset"""
    """if positives is a list of framenumbers, the first frame should be 1"""
    X = prepare_training_data(path_to_csv,filtering=filtering,P=P,featurelist=featurelist)
    num = [int(re.search('\d+',filename).group(0)) for filename in os.listdir(path_to_images)]  
    num_shifted=[numb-1 for numb in num] 
    X_training=X[num_shifted]
    y_training=[0 for i in num_shifted]   
    positives_shifted=[pos-1 for pos in positives]
    for pos in positives_shifted:
        y_training[pos]=1
    return X_training,y_training

def learning_pipeline(path_to_csv,path_to_images,positives,neighbors=3,filtering_data=False,filtering_train=False,P=0.8,featurelist=["angles_w_scaled","angles_b_scaled","wing_dist_male_scaled","wing_dist_female_scaled","abd_dist_scaled","copulationP_scaled"]):
    """pipeline for machine learning"""
    X,y=import_train_test(path_to_csv,path_to_images,positives,filtering=filtering_train,P=P,featurelist=featurelist)
    data=prepare_training_data(path_to_csv, filtering=filtering_data,P=P,featurelist=featurelist)
    logReg,logRegScore,logRegCVScore=train_SGD(X,y,loss="log")
    print("Logistic Regression Test Score: {}".format(logRegScore))
    print("Logistic Regression CV Score: {}".format(logRegCVScore))
    suppVC,SVCScore,SVCCVScore=train_SVC(X,y)
    print("Support Vector Machine Test Score: {}".format(SVCScore))
    print("Support Vector Machine CV Score: {}".format(SVCCVScore))
    knn,knnScore,knnCVScore=train_knn(X,y,neighbors=neighbors)
    print("K Nearest Neighbors Test Score: {}".format(knnScore))
    print("K Nearest Neighbors CV Score: {}".format(knnCVScore))
    randomF,randomFScore,randomFCVScore=train_randomForest(X,y)
    print("Random Forest Test Score: {}".format(randomFScore))
    print("Random Forest CV Score: {}".format(randomFCVScore))
    NB,NBScore=train_NB(X,y)
    print("Naive Bayes Test Score: {}".format(NBScore))
    predictionsLogReg=logReg.predict(data)
    predictionsSVC=suppVC.predict(data)
    predictionsKnn=knn.predict(data)
    predictionsRandomF=randomF.predict(data)
    predictionsNB=NB.predict(data)
    models={"LogReg":{"model":logReg,"score":logRegScore,"CVScore":logRegCVScore,"predictions":predictionsLogReg},
            "SVC":{"model": suppVC,"score":SVCScore,"CVScore":SVCCVScore,"predictions":predictionsSVC},
            "KNN":{"model":knn,"score":knnScore,"CVScore":knnCVScore,"predictions":predictionsKnn},
            "RFC":{"model": randomF,"score":randomFScore,"CVScore":randomFCVScore,"predictions":predictionsRandomF},
            "NB":{"model":NB,"score":NBScore,"predictions":predictionsNB}}
    return models