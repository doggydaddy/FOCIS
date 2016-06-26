#!/bin/bash

# BASH script: 1st_mod3.sh 
# Level: Primary

# Obtain 3dclust-based classification parameters.
# This script requires the following secondary level scripts:
# 3rd_threshold.R 2nd_extractInfo.R 2nd_summarizeCluster.R 

files=`ls component*.nii`
touch mod3_params
for dat in $files
do
	# Parsing, and extracting 3dclust information
	3dmaskdump -mask ~/SVM_framework/brain_mask.nii -noijk -o tmpdump $dat
	thresholds=`3rd_threshold.R tmpdump`
	IFS=" "
	set -- $thresholds
	pt=$2
	nt=$3
	rm tmpdump
	# RAWclusterResults holds the 3dclust output
	3dclust -savemask clusterMask.nii -dxyz=1 -1abs -1clip $pt 2 20 $dat > RAWclusterResults 
	# format the data to be readily parsed 
	sed '/#.*$/d' RAWclusterResults > clusterResults
	rm RAWclusterResults
	# extract 3dcluster information
	2nd_extractInfo.R clusterResults
	# ... if there is any clusters to analyze ...
	if [ -f 2nd_extractInfo_weights ];
	then
		sed 's/".*"//g' 2nd_extractInfo_weights	> the.weights
		sed 's/".*"//g' 2nd_extractInfo_coords > the.coords
		sed 's/".*"//g' 2nd_extractInfo_BBparams > the.BBparams
		rm clusterResults
		rm 2nd_extractInfo_weights 2nd_extractInfo_coords 2nd_extractInfo_BBparams

		# loop processes one cluster in a network at a time, calculating its contribution to the following parameters:
		# whether this cluster has a regular shape (i.e its CM is inside the cluster itself)
		# whether this cluster is in the desired location (i.e its PEAK is inside cortical gray-matter) 
		counter=1;
		while read line
		do
			# if there is another cluster, do the following ... if not, then skip.
			if [[ ! $line =~ [^[:space:]] ]] ; then
				continue
			fi
			# set bash parameters to the line read from the.coords tmp file
			set -- $line
			# label the different parameters
			CMxcord=$1
			CMycord=$2
			CMzcord=$3
			PEAKxcord=$4
			PEAKycord=$5
			PEAKzcord=$6

			# Compile weighted point mask for the cluster's center of mass voxel
			3dcalc -a $dat -expr "((1/2)-(1/52))*step(4-(x-$CMxcord)*(x-$CMxcord)-(y-$CMycord)*(y-$CMycord)-(z-$CMzcord)*(z-$CMzcord))" -prefix CMcenter.nii
			3dcalc -a $dat -expr "(1/52)*step(40-(x-$CMxcord)*(x-$CMxcord)-(y-$CMycord)*(y-$CMycord)-(z-$CMzcord)*(z-$CMzcord))" -prefix CMsurround.nii
			3dcalc -a CMcenter.nii -b CMsurround.nii -expr "a+b" -prefix CMpointCluster.nii
			rm CMcenter.nii CMsurround.nii

			# Compile weighted point mask for the cluster's peak voxel
			3dcalc -a $dat -expr "((1/2)-(1/52))*step(4-(x-$PEAKxcord)*(x-$PEAKxcord)-(y-$PEAKycord)*(y-$PEAKycord)-(z-$PEAKzcord)*(z-$PEAKzcord))" -prefix PEAKcenter.nii
			3dcalc -a $dat -expr "((1/52))*step(4-(x-$PEAKxcord)*(x-$PEAKxcord)-(y-$PEAKycord)*(y-$PEAKycord)-(z-$PEAKzcord)*(z-$PEAKzcord))" -prefix PEAKsurround.nii
			3dcalc -a PEAKcenter.nii -b PEAKsurround.nii -expr "a+b" -prefix PEAKpointCluster.nii
			rm PEAKcenter.nii PEAKsurround.nii
		
			# mask the cortical grey-matter mask with the PEAK coordinate mask to obtain classification parameter for
			# peak activation in cortical grey-matter.
			3dcalc -a '~/SVM_framework/cort_gm_mask.nii' -b 'PEAKpointCluster.nii' -expr 'b*a' -prefix PEAK_clusterInfo.nii
			# mask the CM coordinate mask with the corresponding cluster in the clusterMask.nii (output mask from 3dclust) for classification parameter
			# cluster/component regularity (i.e. cluster/component center of mass lies within the cluster)
			3dcalc -a 'clusterMask.nii' -b 'CMpointCluster.nii' -expr "b*within(a,$counter,$counter)" -prefix CM_clusterInfo.nii
			# creating ASCI dumps
			3dmaskdump -mask ~/SVM_framework/brain_mask.nii -noijk -o dump_PEAK_clusterInfo_$counter PEAK_clusterInfo.nii
			3dmaskdump -mask ~/SVM_framework/brain_mask.nii -noijk -o dump_CM_clusterInfo_$counter CM_clusterInfo.nii
		
			counter=$(($counter+1))
			rm *pointCluster.nii
			rm *_clusterInfo.nii
		done < the.coords
		2nd_summarizeCluster.R >> mod3_params
		rm the.*
		rm dump*
		rm clusterMask.nii
	else
		2nd_zeroFill.R >> mod3_params
	fi
done
