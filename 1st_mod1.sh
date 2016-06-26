#!/bin/bash

# Type: Bash script
# Name: 1st_mod1.sh
# Class: 1st
# Dependencies: 2nd_summarizeMod1.sh, 3rd_threshold.R

files=`ls component*.nii`
for dat in $files 
do
	# --------------------------------
	#       COMMON PREPROCESSING
	# --------------------------------

	# Splitting into positive and negative masks
	3dcalc -a ''$dat'' -expr 'ispositive(a)' -prefix POSMASK_${dat%.hdr}.nii
	3dcalc -a ''$dat'' -expr 'isnegative(a)' -prefix NEGMASK_${dat%.hdr}.nii
	3dcalc -a ''$dat'' -b ''POSMASK_${dat%.hdr}.nii'' -expr 'a*b' -prefix POSVAL_${dat%.hdr}.nii
	3dcalc -a ''$dat'' -b ''NEGMASK_${dat%.hdr}.nii'' -expr '-a*b' -prefix NEGVAL_${dat%.hdr}.nii

	# Creating beforecomparison dump
	3dcalc -a ''POSVAL_${dat%.hdr}.nii'' -b ''NEGVAL_${dat%.hdr}.nii'' -expr 'a+b' -prefix RES_VAL_${dat%.hdr}.nii
	3dmaskdump -mask ~/SVM_framework/brain.nii -noijk -o DUMP_BEFORE_${dat%.hdr} RES_VAL_${dat%.hdr}.nii    
	# --------------------------------

	# Grabbing threshold parameters
	3dmaskdump -mask ~/SVM_framework/brain_mask.nii -noijk -o tmpdump $dat
	thresholds=`3rd_threshold.R tmpdump`
	IFS=" "
	set -- $thresholds
	pt=$2
	nt=$3

	3dcalc -a ''POSVAL_${dat%.hdr}.nii'' -expr "ispositive(a-$pt)" -prefix POS_THRESHED_${dat%.hdr}.nii
	3dcalc -a ''NEGVAL_${dat%.hdr}.nii'' -expr "ispositive(a-$nt)" -prefix NEG_THRESHED_${dat%.hdr}.nii

	# -----------------------------------
	# MODULE 1: Cortical GM mask weighting
	# -----------------------------------
	# Perform tissuepriors weighting for grey matter
	3dcalc -a '~/SVM_framework/cort_gm_mask.nii' -b ''POS_THRESHED_${dat%.hdr}.nii'' -expr 'step(a)*step(b)' -prefix POSRES_GREY_${dat%.hdr}.nii
	3dcalc -a '~/SVM_framework/cort_gm_mask.nii' -b ''NEG_THRESHED_${dat%.hdr}.nii'' -expr 'step(a)*step(b)' -prefix NEGRES_GREY_${dat%.hdr}.nii

	# Creating ASCIdumps
	3dmaskdump -mask ~/SVM_framework/brain_mask.nii -noijk -o DUMP_NEG_MASKED_${dat%.hdr} NEGRES_GREY_${dat%.hdr}.nii
	3dmaskdump -mask ~/SVM_framework/brain_mask.nii -noijk -o DUMP_POS_MASKED_${dat%.hdr} POSRES_GREY_${dat%.hdr}.nii

	# Cleanup
	rm POSRES_GREY_${dat%.hdr}.nii
	rm NEGRES_GREY_${dat%.hdr}.nii
	# rm RES_GREY_${dat%.hdr}.nii
	# -----------------------------------

	# --------------------------------
	#         COMMON CLEANUP
	# --------------------------------
	rm tmpdump
	rm POSMASK_${dat%.hdr}.nii
	rm NEGMASK_${dat%.hdr}.nii
	rm POSVAL_${dat%.hdr}.nii
	rm NEGVAL_${dat%.hdr}.nii
	rm RES_VAL_${dat%.hdr}.nii
	rm POS_THRESHED_${dat%.hdr}.nii
	rm NEG_THRESHED_${dat%.hdr}.nii
	# --------------------------------
done
2nd_summarizeMod1.R
rm DUMP_*

