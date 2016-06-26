#!/bin/bash

target_dir=$1
cp ~/SVM_framework/infiltrator_script.sh $target_dir
cd $target_dir
./infiltrator_script.sh $2
cp melodic_mix ..
cp component*.nii ..
rm component*.nii
cd ..
1st_mod1.sh
1st_mod3.sh
1st_mod5.R
rm component*.nii
rm melodic_mix
3rd_sortClassifiers.R > $3
rm mod1_params
rm mod3_params
rm mod5_params

