import pandas as pd
import numpy as np
import math
import scipy
import matplotlib.pyplot as plt
from scipy import io

def load_csv_file(path):
    """loads a csv file of deeplabcut data 
    and returns a pandas dataframe"""
    datatable=pd.read_csv(path,header=1)
    FemaleHeadX=datatable['FemaleHead'][1:]
    FemaleHeadY=datatable['FemaleHead.1'][1:]
    FemaleHeadP=datatable['FemaleHead.2'][1:]
    FemaleWing1X=datatable['FemaleWing1'][1:]
    FemaleWing1Y=datatable['FemaleWing1.1'][1:]
    FemaleWing1P=datatable['FemaleWing1.2'][1:]
    FemaleWing2X=datatable['FemaleWing2'][1:]
    FemaleWing2Y=datatable['FemaleWing2.1'][1:]
    FemaleWing2P=datatable['FemaleWing2.2'][1:]
    MaleHeadX=datatable['MaleHead'][1:]
    MaleHeadY=datatable['MaleHead.1'][1:]
    MaleHeadP=datatable['MaleHead.2'][1:]
    MaleWing1X=datatable['MaleWing1'][1:]
    MaleWing1Y=datatable['MaleWing1.1'][1:]
    MaleWing1P=datatable['MaleWing1.2'][1:]
    MaleWing2X=datatable['MaleWing2'][1:]
    MaleWing2Y=datatable['MaleWing2.1'][1:]
    MaleWing2P=datatable['MaleWing2.2'][1:]
    MaleAbdomenX = datatable['MaleAbdomen'][1:]
    MaleAbdomenY = datatable['MaleAbdomen.1'][1:]
    MaleAbdomenP = datatable['MaleAbdomen.2'][1:]
    CopulationX=datatable['Copulation'][1:]
    CopulationY=datatable['Copulation.1'][1:]
    CopulationP=datatable['Copulation.2'][1:]
    localvars = locals()
    del localvars["path"]
    del localvars["datatable"]
    df = pd.DataFrame(data=localvars)
    dffloat=df.astype('float32')
    return dffloat


def signDeltax(deltaxFly,deltayFly):
    """determines the sign of the fly's orientation - 
    necessary for determining 
if they face in the same direction"""
    if deltaxFly >0:
        signDeltaxFly =  1
    elif deltaxFly < 0:
        signDeltaxFly = -1
    else:
        if deltayFly < 1:
            signDeltaxFly =  1
        else:
            signDeltaxFly = -1
    return signDeltaxFly

def signDeltax2(deltaxFly):
    """slight variation of signDeltax"""
    if deltaxFly >0:
        signDeltaxFly =  1
    elif deltaxFly < 0:
        signDeltaxFly = -1
    else:
        signDeltaxFly = 0
    return signDeltaxFly


def mating_angle_from_angles(maleAngle,femaleAngle,relativeSign):
    """calculates the mating angles based on the male and female angle 
and the relative sign of their facing direction"""
    if relativeSign >0:
        matingAngle = abs(maleAngle - femaleAngle)
    else:
        matingAngle = math.pi - abs(maleAngle - femaleAngle)
    return matingAngle
    

def mating_angle (FemaleWing1X,FemaleWing1Y,
                  FemaleWing2X,FemaleWing2Y,
                  MaleWing1X,MaleWing1Y,
                  MaleWing2X,MaleWing2Y):
    """determines mating angle from the wing position data"""
    deltaxF =  FemaleWing2X -  FemaleWing1X
    deltayF =  FemaleWing2Y -  FemaleWing1Y
    deltaxM =  MaleWing2X   -  MaleWing1X
    deltayM =  MaleWing2Y   -  MaleWing1Y

    femaleAngle = np.arctan(deltayF/deltaxF)
    maleAngle   = np.arctan(deltayM/deltaxM)

    signDeltaxF = signDeltax(deltaxF,deltayF)
    signDeltaxM = signDeltax(deltaxM,deltayM)
    relativeSign = signDeltaxF * signDeltaxM
    matingAngle = mating_angle_from_angles(maleAngle,
                                           femaleAngle,
                                           relativeSign)
    return matingAngle
    

def mating_angle_pd_df(df):
    """applies the mating angle function to a row in a pandas dataframe"""
    matingAngleRow = mating_angle(df.FemaleWing1X,df.FemaleWing1Y,
                                  df.FemaleWing2X,df.FemaleWing2Y,
                                  df.MaleWing1X,df.MaleWing1Y,
                                  df.MaleWing2X,df.MaleWing2Y)
    return matingAngleRow

    
def mating_angles_all_rows(path):
    """applies the mating angle function to all rows in a dataframe"""
    data=load_csv_file(path)
    angles=data.apply(mating_angle_pd_df, axis=1)
    return angles

def mating_angle_from_body_axis(FemaleHeadX, FemaleHeadY,
                                CopulationX,CopulationY,
                                MaleHeadX,MaleHeadY,
                                MaleAbdomenX,MaleAbdomenY):
    """determines mating angle from the head and abdomen position data"""
    deltaxF =  FemaleHeadX -  CopulationX
    deltayF =  FemaleHeadY -  CopulationY
    deltaxM =  MaleHeadX   -  MaleAbdomenX
    deltayM =  MaleHeadY   -  MaleAbdomenY

    femaleAngle = np.arctan(deltayF/deltaxF)
    maleAngle   = np.arctan(deltayM/deltaxM)

    signDeltaxF = signDeltax2(deltaxF)
    if  signDeltaxF == 0:
        signDeltaxF = signDeltax2(deltayF)
        signDeltaxM = signDeltax2(deltayM)
        femaleAngle = signDeltaxF * math.pi/2
    else:
        signDeltaxM = signDeltax2(deltaxM)
        if  signDeltaxM == 0:
            signDeltaxF = signDeltax2(deltayF)
            signDeltaxM = signDeltax2(deltayM)
            maleAngle = signDeltaxM * math.pi/2
    relativeSign = signDeltaxF * signDeltaxM
    matingAngle = mating_angle_from_angles(maleAngle,
                                           femaleAngle,
                                           relativeSign)
    return matingAngle
     
def mating_angle_from_body_axis_pd_df(df):
    """applies the mating_angle_from_body_axis function to a row in a pandas dataframe"""
    matingAngleRow = mating_angle_from_body_axis(df.FemaleHeadX,df.FemaleHeadY,
                                  df.CopulationX,df.CopulationY,
                                  df.MaleHeadX,df.MaleHeadY,
                                  df.MaleAbdomenX,df.MaleAbdomenY)
    return matingAngleRow

    
def mating_angles_all_rows_from_body_axis(path):
    """applies the mating_angle_from_body_axis function to all rows in a dataframe"""
    data=load_csv_file(path)
    angles=data.apply(mating_angle_from_body_axis_pd_df, axis=1)
    return angles

def mating_angles_from_wing_and_body_axis(path):
    """loads the csv file of deeplabcut data
    specified as the path argument and determines mating angle
    from both wing and body axis data;
    returns the angles based on wing data and the angles based on body axis
    (in this order)
    This is the function that should be used if you want no filtering of data"""
    data=load_csv_file(path)
    angles_w=data.apply(mating_angle_pd_df, axis=1)
    angles_b=data.apply(mating_angle_from_body_axis_pd_df, axis=1)
    return angles_w,angles_b


def filter_by_likelihood_body(data,P):
    """filteres the data (in pandas dataframe format)
    by those where body axis parameters have a 
    likelihood >P """
    isLargeHeadP=data.MaleHeadP>P
    isLargeAbdP=data.MaleAbdomenP>P
    isLargeHeadFP=data.FemaleHeadP>P
    isLargeAbdFP=data.CopulationP>P
    data_filtered=data[isLargeHeadP & isLargeAbdP & isLargeHeadFP & isLargeAbdFP]
    return data_filtered

def filter_by_likelihood_wing(data,P):
    """filteres the data (in pandas dataframe format)
    by those where wing parameters have a 
    likelihood >P """
    isLargeLWingM=data.MaleWing1P>P
    isLargeRWingM=data.MaleWing2P>P
    isLargeLWingF=data.FemaleWing1P>P
    isLargeRWingF=data.FemaleWing2P>P
    data_filtered=data[isLargeLWingM & isLargeRWingM  & isLargeLWingF &isLargeRWingF]
    return data_filtered


def filter_all_likelihood(data,P):
    """filteres the data (in pandas dataframe format)
    by those where both body axis and wing parameters have a 
    likelihood >P """
    data_filtered1=filter_by_likelihood_body(data,P)
    data_filtered2=filter_by_likelihood_wing(data_filtered1,P)
    return data_filtered2
    
def filtered_mating_angles(path,P):
    """loads the csv file of deeplabcut data
    specified as the path argument and determines mating angle
    from both wing and body axis data;
    returns the angles based on wing data and the angles based on body axis
    (in this order)
    This is the function that should be used if you want filtering of data by 
    those with a likelihood > P"""
    data=load_csv_file(path)
    dataF=filter_all_likelihood(data,P)
    angles_w=dataF.apply(mating_angle_pd_df, axis=1)
    angles_b=dataF.apply(mating_angle_from_body_axis_pd_df, axis=1)
    return angles_w,angles_b

def wing_distance_male(df):
    """calculates distance between wings"""
    wing_distance_male = wing_distance(df.MaleWing1X,df.MaleWing1Y,
                                        df.MaleWing2X,df.MaleWing2Y)
    return wing_distance_male

def wing_distance_female(df):
    wing_distance_female = wing_distance(df.FemaleWing1X,df.FemaleWing1Y,
                                        df.FemaleWing2X,df.FemaleWing2Y)
    return wing_distance_female

def wing_distance(wing1x,wing1y, wing2x,wing2y):
    distance=math.sqrt((wing1x-wing2x)**2+(wing1y-wing2y)**2)
    return distance     

def wing_distance_all_rows(path):
    """loads the csv file of deeplabcut data
    specified as the path argument and determines wing distance
   This is the function that should be used if you want no filtering of data"""
    data=load_csv_file(path)
    wing_dist_male=data.apply(wing_distance_male, axis=1)
    wing_dist_female=data.apply(wing_distance_female, axis=1)
    return wing_dist_male, wing_dist_female

def filtered_wing_distance(path,P):
    """loads the csv file of deeplabcut data
    specified as the path argument and determines wing distance;
    This is the function that should be used if you want filtering of data by 
    those with a likelihood > P"""
    data=load_csv_file(path)
    dataF=filter_all_likelihood(data,P)
    wing_dist_male=dataF.apply(wing_distance_male, axis=1)
    wing_dist_female=dataF.apply(wing_distance_female, axis=1)
    return wing_dist_male, wing_dist_female

def filtered_outputs(path,P):
    """loads the csv file of deeplabcut data
    specified as the path argument and determines mating angle
    from both wing and body axis data as well as wing distance;
    returns the angles based on wing data and the angles based on body axis, 
    male wing distance, female wing distance,distance between male and female abdomen
    (in this order)
    This is the function that should be used if you want filtering of data by 
    those with a likelihood > P"""
    data=load_csv_file(path)
    dataF=filter_all_likelihood(data,P)
    angles_w=dataF.apply(mating_angle_pd_df, axis=1)
    angles_b=dataF.apply(mating_angle_from_body_axis_pd_df, axis=1)
    wing_dist_male=dataF.apply(wing_distance_male, axis=1)
    wing_dist_female=dataF.apply(wing_distance_female, axis=1)
    abd_dist=dataF.apply(abd_distance, axis=1)
    head_dist=data.apply(head_distance, axis=1)
    return angles_w,angles_b,wing_dist_male,wing_dist_female,abd_dist,head_dist

def unfiltered_outputs(path):
    """loads the csv file of deeplabcut data
    specified as the path argument and determines mating angle
    from both wing and body axis data as well as wing distance;
    returns the angles based on wing data and the angles based on body axis, 
    male wing distance, female wing distance,distance between male and female abdomen
    (in this order)
    This is the function that should be used if you don't want filtering of data by 
    those with a likelihood > P"""
    data=load_csv_file(path)
    angles_w=data.apply(mating_angle_pd_df, axis=1)
    angles_b=data.apply(mating_angle_from_body_axis_pd_df, axis=1)
    wing_dist_male=data.apply(wing_distance_male, axis=1)
    wing_dist_female=data.apply(wing_distance_female, axis=1)
    abd_dist=data.apply(abd_distance, axis=1)
    head_dist=data.apply(head_distance, axis=1)
    copulationP=data.CopulationP
    return angles_w,angles_b,wing_dist_male,wing_dist_female,abd_dist,head_dist,copulationP

def tilting_row(df):
    """calculates tilting index for one row"""
    tilting = (df.male_wingdist/df.female_wingdist)
    return tilting

def tilting_index(malewingdist,femalewingdist,copstartframe):
    """applies tilting_row function to the dataframe,
    taking all frames before copstartframe as baseline"""
    male_resting=np.median(malewingdist[1:copstartframe-1])
    female_resting=np.median(femalewingdist[1:copstartframe-1])
    relative_rest=male_resting/female_resting
    wingdist_both=pd.concat({"male_wingdist":malewingdist,"female_wingdist":femalewingdist},axis=1)
    tilting = wingdist_both[copstartframe:].apply(tilting_row,axis=1)
    tilting_ind=tilting/relative_rest
    return tilting_ind

def tilting_index_all_frames(malewingdist,femalewingdist,copstartframe):
    """applies tilting_row function to the dataframe,
    taking all frames before copstartframe as baseline"""
    male_resting=np.median(malewingdist[1:copstartframe-1])
    female_resting=np.median(femalewingdist[1:copstartframe-1])
    relative_rest=male_resting/female_resting
    wingdist_both=pd.concat({"male_wingdist":malewingdist,"female_wingdist":femalewingdist},axis=1)
    tilting = wingdist_both.apply(tilting_row,axis=1)
    tilting_ind=tilting/relative_rest
    return tilting_ind

def abd_distance(df):
    distanceMF = distance(df.MaleAbdomenX,df.MaleAbdomenY,
                                        df.CopulationX,df.CopulationY)
    return distanceMF

def head_distance(df):
    distanceMF = distance(df.MaleHeadX,df.MaleHeadY,
                                        df.FemaleHeadX,df.FemaleHeadY)
    return distanceMF

def distance(xmale,ymale, xfemale,yfemale):
    distance=math.sqrt((xmale-xfemale)**2+(ymale-yfemale)**2)
    return distance     

def abd_distance_all_rows(path):
    """loads the csv file of deeplabcut data
    specified as the path argument and determines wing distance
   calculates distance between male and female abdomen"""
    data=load_csv_file(path)
    dist=data.apply(abd_distance, axis=1)
    return dist

def load_feat_file(path):
    """loads the angle_between data from the feat.mat file.
    returns feat.data and angle_between as 2 variables"""
    feat=scipy.io.loadmat(path,matlab_compatible=True)
    dataArr = feat['feat']['data'][0][0]
    angle_between = dataArr[:,:,10]
    return feat, angle_between