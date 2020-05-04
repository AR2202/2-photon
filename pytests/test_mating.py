import sys
sys.path.append("../mating_analysis")
import mating_angles_model2
from mating_angles_model2 import signDeltax2,mating_angle_from_angles,mating_angle_from_body_axis,mating_angle_from_body_axis_pd_df
from mating_angles_model2 import filter_by_likelihood_body,load_csv_file,unfiltered_outputs,filtered_outputs,centroids,centroid_distance
import math
import pytest
import pandas as pd
import numpy as np

testdatapath="testdata_pytest/exampledata.csv"

def test_signDeltax2():
    assert signDeltax2(3) == 1
    assert signDeltax2(-2) == -1
    assert signDeltax2(0) == 0

def test_mating_angle_from_angles():
    assert mating_angle_from_angles(1.5,0.75,1) == 0.75
    assert mating_angle_from_angles(-1.5,-0.75,1) == 0.75
    assert mating_angle_from_angles(0.75,1.5,1) == 0.75
    assert mating_angle_from_angles(-0.75,0.75,1) == 1.5

    assert mating_angle_from_angles(-0.75,0.75,-1) == math.pi-1.5
    assert mating_angle_from_angles(-0.75,0.75,0) == math.pi-1.5


def test_mating_angle_from_body_axis():
    assert mating_angle_from_body_axis(2,1,1,0,-1,2,0,1) == math.pi/2

def test_zero_division_mating_angle_from_body_axis():
    with pytest.raises(ZeroDivisionError):
        mating_angle_from_body_axis(2,0,1,0,-0,2,0,1)
    
def test_mating_angle_from_body_axis_pd_df():
    datadict={"FemaleHeadX": [2],"FemaleHeadY":[1],
    "FemaleAbdomenX":[1],"FemaleAbdomenY":[0],
    "MaleHeadX":[-1],"MaleHeadY":[2],
    "MaleAbdomenX":[0],"MaleAbdomenY":[1]}
    df=pd.DataFrame(datadict)
    angles=df.apply(mating_angle_from_body_axis_pd_df, axis=1)
    assert angles[0] == math.pi/2

def test_filter_by_likelihood_body():
    testdata=load_csv_file(testdatapath)
    filtered_data,rows=filter_by_likelihood_body(testdata,0.8)
    filtered_data_female_A=filtered_data[filtered_data.FemaleAbdomenP>0.8]
    filtered_data_female_H=filtered_data[filtered_data.FemaleHeadP>0.8]
    filtered_data_male_A=filtered_data[filtered_data.MaleAbdomenP>0.8]
    filtered_data_male_H=filtered_data[filtered_data.MaleHeadP>0.8]
    assert len(rows)==len(filtered_data)
    assert len(filtered_data_female_A)==len(filtered_data)
    assert len(filtered_data_female_H)==len(filtered_data)
    assert len(filtered_data_male_A)==len(filtered_data)
    assert len(filtered_data_male_H)==len(filtered_data)

def test_filtered_outputs():
    angles_b,wing_dist_male,abd_dist,head_dist,rownumbers=unfiltered_outputs(testdatapath)
    angles_b_filter0,wing_dist_male_filter0,abd_dist_filter0,head_dist_filter0,rownumbers_filter0=filtered_outputs(testdatapath,0)
    angles_b_filter08,wing_dist_male_filter08,abd_dist_filter08,head_dist_filter08,rownumbers_filter08=filtered_outputs(testdatapath,0.8)
    
    assert len(angles_b)==len(angles_b_filter0),"filtering by P=0 should not change data"
    assert angles_b[1]==angles_b_filter0[1],"filtering by P=0 should not change data"
    assert angles_b[10000]==angles_b_filter0[10000],"filtering by P=0 should not change data"
    assert angles_b[rownumbers_filter08[6000]]==angles_b_filter08[rownumbers_filter08[6000]],"data at corresponding indices should match"
    assert len(rownumbers_filter08)==len(wing_dist_male_filter08),"length of row numbers should match length of data"
    assert len(angles_b)!=len(angles_b_filter08),"filtering by P=0.8 should change data"
    assert rownumbers_filter08[6000]!=6000,"there are rownumbers missing in the filtered dataset"
    assert rownumbers_filter08[0]==0,"rownumbers should be 0 based"
    #assert 7 not in rownumbers_filter08

def test_removeWall_option():
    angles_b,wing_dist_male,abd_dist,head_dist,rownumbers=unfiltered_outputs(testdatapath)
    angles_b_r,wing_dist_male_r,abd_dist_R,head_dist_r,rownumbers_r=unfiltered_outputs(testdatapath,removeWall=True,minWallDist=50)
    assert len(angles_b)!=len(angles_b_r),"filtering by distance to wall should remove data"
    assert len(rownumbers_r) >0
    
    assert len(rownumbers) ==0
    assert len(rownumbers_r)==len(angles_b_r)
    assert len(angles_b_r)!=len(angles_b)
    assert 0 in rownumbers_r 
    assert 12231 not in rownumbers_r 
    assert 6000 in rownumbers_r 

def test_centroids():
    data=load_csv_file(testdatapath)
    centroidx,centroidy,d=centroids(data)
    assert d>550
    assert d<600
    assert centroidx> 300
    assert centroidy>300
    assert centroidx< 400
    assert centroidy<400

def test_centroid_distance():
    data=load_csv_file(testdatapath)
    centroidx,centroidy,d=centroids(data)

    distanceToCentroid=data.apply(lambda df: centroid_distance(df,centroidx,centroidy), axis=1)
    dataB=data[distanceToCentroid<((d/2)-10)]
    rownumbers=np.where(distanceToCentroid<((d/2)-50))[0]
    assert distanceToCentroid[13673]>250,"frame 4257 should have a larger than 200 px distance from the centroid"
    assert distanceToCentroid[13673]>((d/2)-50),"frame 4257 should have a larger than 200 px distance from the centroid"
    assert distanceToCentroid[8815]<((d/2)-50),"frame 4257 should have a larger than 200 px distance from the centroid"
    assert d/2<300,"the radius of the chamber should be smaller than 300 px"
    assert 12231 not in rownumbers,"frame 4257 should not be in rownumbers"
    assert 8815 in rownumbers,"frame 19168 should  be in rownumbers"

def test_npwhere():
    l=np.array([0,1,2,3,4,5])
    above3=np.where(l>3)[0]
    assert 4 in above3
    assert 2 not in above3

