import pandas as pd
import numpy as np
import math

def load_csv_file(path):
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

def mating_angle_from_angles(maleAngle,femaleAngle,relativeSign):
    if relativeSign >0:
        matingAngle = maleAngle + femaleAngle
    else:
        matingAngle = math.pi - (maleAngle + femaleAngle)
    return matingAngle
    

def mating_angle(FemaleWing1X,FemaleWing1Y,FemaleWing2X,FemaleWing2Y,MaleWing1X,MaleWing1Y,MaleWing2X,MaleWing2Y):
    deltaxF =  FemaleWing2X -  FemaleWing1X
    deltayF =  FemaleWing2Y -  FemaleWing1Y
    deltaxM =  MaleWing2X   -  MaleWing1X
    deltayM =  MaleWing2Y   -  MaleWing1Y

    femaleAngle = abs(np.arctan(deltayF/deltaxF))
    maleAngle   = abs(np.arctan(deltayM/deltaxM))

    signDeltaxF = signDeltax(deltaxF,deltayF)
    signDeltaxM = signDeltax(deltaxM,deltayM)
    relativeSign = signDeltaxF * signDeltaxM
    matingAngle = mating_angle_from_angles(maleAngle,femaleAngle,relativeSign)
    return matingAngle
    

def mating_angle_pd_df(df):
    matingAngleRow = mating_angle(df.FemaleWing1X,df.FemaleWing1Y,df.FemaleWing2X,df.FemaleWing2Y,df.MaleWing1X,df.MaleWing1Y,df.MaleWing2X,df.MaleWing2Y)
    return matingAngleRow

    


    
