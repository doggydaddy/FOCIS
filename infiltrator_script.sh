#!/bin/bash
for (( i=0 ; i<$1 ; i++ ))
do
	if [ "$i" -lt 9 ]; then
		3dTcat -prefix component_0$(($i+1)).nii melodic_IC.nii.gz''[$i]''
	else
		3dTcat -prefix component_$(($i+1)).nii melodic_IC.nii.gz''[$i]''
	fi
done

