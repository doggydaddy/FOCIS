#!/usr/bin/env Rscript

# Rscript, secondary-level
# used to extract cluster coordinates and cluster weights
# from 3dclust output.
# output is standarized to 2 files, 1 for the coordinates (2nd_extractInfo_coords)
# and 1 for the weights (2nd_extractInfo_weights)

args <- commandArgs(TRUE);
clusterDump <- tryCatch({
	read.table(args[1]);
}, error = function (war) {
	print( c(0,0,0) );
	q("no");
});
clusterSizes <- clusterDump[,1];
nrOfClusters <- length(clusterSizes);
totalClusterSize <- sum(clusterSizes);

a.weights <- array(0, dim=nrOfClusters);
a.coords <- array(0, dim=c(nrOfClusters,6) );
a.BBparams <- array(0, dim=c(nrOfClusters,3));

# coordinate file outputs the follwing in order:
# cm.x cm.y, cm.z peak.x peak.y peak.z
for ( i in 1:nrOfClusters ) {
	
	# extracting coordinate information for CM & PEAK, and cluster weights
	a.coords[i,1] <- clusterDump[i,2];
	a.coords[i,2] <- clusterDump[i,3];
	a.coords[i,3] <- clusterDump[i,4];
	a.coords[i,4] <- clusterDump[i,14];
	a.coords[i,5] <- clusterDump[i,15];
	a.coords[i,6] <- clusterDump[i,16];
	a.weights[i] <- clusterSizes[i] / totalClusterSize;

	# performing calculatin of classification parameters that can be done now
	
	# loading bounding box information
	min.RL <- clusterDump[i,5]; max.RL <- clusterDump[i,6];
	min.AP <- clusterDump[i,7]; max.AP <- clusterDump[i,8];
	min.IS <- clusterDump[i,9]; max.IS <- clusterDump[i,10];
	cluster.vol <- clusterDump[i,1];
	# calculating bounding box size
	RL <- max.RL - min.RL; AP <- max.AP - min.AP; IS <- max.IS - min.IS;
	BB.vol <- RL*AP*IS;

	# calculating parameters	
	BB.max.irreg <- ( max(RL, AP, IS) - min(RL, AP, IS) ) / max(RL, AP, IS);	
	# BB.midline.irreg is a parameter optimized for detection of midline
	# artefacts, which CM inside cluster and BB fill might not be suitable	
	BB.midline.irreg <- AP / RL;
	BB.fill <- cluster.vol / BB.vol; 
	
	a.BBparams[i,1] <- BB.max.irreg;
	a.BBparams[i,2] <- BB.midline.irreg;
	a.BBparams[i,3] <- BB.fill;

}
write.table(a.coords, file="2nd_extractInfo_coords");
write.table(a.weights, file="2nd_extractInfo_weights");
write.table(a.BBparams, file="2nd_extractInfo_BBparams");
