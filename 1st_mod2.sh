#!/bin/bash

#time-course based parameters.
#time-course = extract average ideal using thresholded component as a mask
#calculate classification parameter for INDIVIDUAL subjects first before group average
#(So to avoid averaging out inter-subject flucuations)

components=`ls component*.nii`
touch mod2_params
for comp in $components
do
	# Splitting into positive and negative masks
	3dcalc -a ''$comp'' -expr 'ispositive(a)' -prefix POSMASK_${comp%.hdr}.nii
	3dcalc -a ''$comp'' -expr 'isnegative(a)' -prefix NEGMASK_${comp%.hdr}.nii
	3dcalc -a ''$comp'' -b ''POSMASK_${comp%.hdr}.nii'' -expr 'a*b' -prefix POSVAL_${comp%.hdr}.nii
	3dcalc -a ''$comp'' -b ''NEGMASK_${comp%.hdr}.nii'' -expr '-a*b' -prefix NEGVAL_${comp%.hdr}.nii

	# Creating beforecomparison dump
	#3dcalc -a ''POSVAL_${comp%.hdr}.nii'' -b ''NEGVAL_${comp%.hdr}.nii'' -expr 'a+b' -prefix RES_VAL_${comp%.hdr}.nii
	#3dmaskdump -mask ~/SVM_framework/brain.nii -noijk -o DUMP_BEFORE_${comp%.hdr} RES_VAL_${comp%.hdr}.nii    
	# --------------------------------

	# Grabbing threshold parameters
	3dmaskdump -mask ~/SVM_framework/brain.nii -noijk -o tmpdump $comp
	thresholds=`3rd_threshold.R tmpdump`
	OLD_IFS=$IFS
	IFS=" "
	set -- $thresholds
	pt=$2
	nt=$3
	# Making a mask out of the component
	3dcalc -a ''POSVAL_${comp%.hdr}.nii'' -expr "ispositive(a-$pt)" -prefix POS_THRESHED_${comp%.hdr}.nii
	3dcalc -a ''NEGVAL_${comp%.hdr}.nii'' -expr "ispositive(a-$nt)" -prefix NEG_THRESHED_${comp%.hdr}.nii
	3dcalc -a ''POS_THRESHED_${comp%.hdr}.nii'' -b "NEG_THRESHED_${comp%.hdr}.nii" -expr 'a+b' -prefix component_mask.nii

	IFS=$OLD_IFS
	data=`ls Set2*.nii`
	for dat in $data
	do
		#parsing, and extrating mask information
		3dROIstats -mask component_mask.nii $dat > ideal
		2nd_calcMod2Params.R ideal >> tmp_mod2_params_${comp%.hdr}
	done
	3rd_avgMod2Params.R tmp_mod2_params_${comp%.hdr} >> mod2_params
	rm ideal
	rm tmpdump
	rm component_mask.nii
	rm tmp_mod2_params_*
	rm NEG*
	rm POS*
done

timecourses=`ls tc.1D`

 
