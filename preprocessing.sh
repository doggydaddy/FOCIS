#!/bin/bash

#preprocessing of resting state
#this script requires a and a template image called brain.nii	
subs=`ls *.nii`
for sub in $subs
do
	#deoblique first
	3dWarp -deoblique -prefix  deoblique.nii  $sub 

	#exclude the first 10 volmes
	3dTcat -prefix ex10_$sub deoblique.nii'[10..$]'
	rm deoblique.nii

	#do the motion correction first
	3dvolreg  -prefix MC_$sub -base 10  -zpad 4 \
		-1Dfile  mc_${sub%.nii}.1D  ex10_$sub
		3dTstat -mean -prefix mean_$sub MC_$sub

	#strip the skull of the mean image using bet from fsl
	bet mean_$sub  stripped_mean_$sub -f 0.4
	gzip -d stripped_mean_$sub.gz

	#do the registration of the mean image to TT
	3dAllineate -base brain.nii -source  stripped_mean_$sub                \
		   -warp affine_general    -twopass  -cost mi                  \
		   -1Dmatrix_save  m2tt${sub%.nii} -master brain.nii            \
		   -mast_dxyz 4 -prefix mean2TT_mean_$sub

	cat_matvec -ONELINE m2tt${sub%.nii}.aff12.1D  > m2tt${sub%.nii} 

	#do the registration of the entire seires 
	3dAllineate -base brain.nii -source  MC_$sub     \
		   -warp affine_general    -twopass                 \
		   -1Dmatrix_apply m2tt${sub%.nii} -master brain.nii  \
		   -mast_dxyz 4 -prefix x2tt_MC_$sub 

	#make a mask out of the mean image
	3dAutomask -dilate 1  -prefix mask_mean_x2tt_MC$sub mean2TT_mean_$sub

	#converting to float
	3dcalc -a x2tt_MC_$sub -prefix x2tt_MCf_$sub -datum float -expr 'a'

	#do the band-pass filtering  (1)
	3dFourier -lowpass 0.1 -prefix Set1_$sub x2tt_MCf_$sub 

	#do the detrend  here (2)
	3dDetrend -prefix Set2_$sub -polort 3 Set1_$sub 

	#cleanup
	rm ex10_$sub x2tt_MC_$sub x2tt_MCf_$sub mask_mean_x2tt_MC$sub m2tt${sub%.nii}
	rm m2tt${sub%.nii}.aff12.1D stripped_mean_$sub mean_$sub mean2TT_mean_$sub
	rm MC_$sub mc_$sub
    rm mc_${sub%.nii}.1D
done
