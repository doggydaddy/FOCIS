#!/bin/bash

for(( a=30; a<=30; a++ ))
do
	#fsl5.0-melodic -i filesList -o ICAoutput_$a -d $a -m brain_mask_4mm.nii --Oall
	#cp infiltrator_script.sh ICAoutput_$a
	cd ICAoutput_$a
	./infiltrator_script.sh $a
	cp melodic_mix ..
	cp component*.nii ..
	cd ..
	./1st_mod1.sh
	./1st_mod2.sh
	./1st_mod3.sh
	./1st_mod4.sh
	./1st_mod5.R
	#./SVM_classification.R mod1_params mod3_params
	mv mod1_params mod1_params_$a
	mv mod2_params mod2_params_$a
	mv mod3_params mod3_params_$a
	mv mod4_params mod4_params_$a
	mv mod5_params mod5_params_$a
	rm component*.nii
	rm melodic_mix
done

