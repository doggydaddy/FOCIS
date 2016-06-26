#!/usr/bin/env Rscript

# Name: 2nd_summarizeCluster.R
# Type: Rscipt

# Listing files for calculatation of:
# Cluster regularity: Center of Mass in cluster
# Peak activation in grey-matter
CM.dumps <- list.files(pattern="dump_CM_clusterInfo_*");
PEAK.dumps <- list.files(pattern="dump_PEAK_clusterInfo_*");
weights.dump <- read.table('the.weights');
BBparams.dump <- read.table('the.BBparams');

cluster.weights <- weights.dump[,1];
# irrespectively of how one counts, 
# the 14th entry is the center of the 3x3 cube of the "point cluster"
n <- length(CM.dumps);
m <- length(cluster.weights);
if(m != n) print("lengths do not match!!! something is seriously wrong ...\n");

results <- array( 0 , dim=c(n, 5) );

for (i in 1:n) {
	# Center of Mass parsing	
	CM.file <- read.table( CM.dumps[i] );
	CM.data <- CM.file[,1];
	CM.data <- CM.data[CM.data != 0];
	# PEAK activation in grey-matter calculations	
	PEAK.file <- read.table( PEAK.dumps[i] );
	PEAK.data <- PEAK.file[,1];
	PEAK.data <- PEAK.data[PEAK.data != 0];
	# Performing summation and weighting 	
	results[i,1] <- sum(CM.data) * cluster.weights[i];
	results[i,2] <- sum(PEAK.data) * cluster.weights[i];

	# loading the BB params into the same output
	results[i,3] <- BBparams.dump[i,1] * cluster.weights[i];
	results[i,4] <- BBparams.dump[i,2] * cluster.weights[i];
	results[i,5] <- BBparams.dump[i,3] * cluster.weights[i];
}

script.output <- colSums(results);
print( script.output );
