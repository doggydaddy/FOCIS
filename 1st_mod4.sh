#!/bin/bash

# Unthresholded spatial t-values density plot (histogram) parameters.

components=`ls component*.nii`
touch mod4_params
for comp in $components
do
	3dmaskdump -mask ~/SVM_framework/brain.nii -noijk -o DUMP_${comp%.hdr} $comp
	2nd_calcMod4Params.R DUMP_${comp%.hdr} >> mod4_params	
	rm DUMP_${comp%.hdr}
done
