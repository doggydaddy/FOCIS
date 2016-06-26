#!/usr/bin/env Rscript

# Name: 2nd_summarizeCluster.R
# Type: Rscipt


predictAll <- function () {
source('rfunctions.R');
mod1 <- list.files(pattern='mod1_params_*');
N <- length(mod1);

output <- array(0, dim=c(N, 2));
c<-1;
for( i in 20:100 ) { 
	print("Loading data ... ");
	index <- c(1, 8, 11, 15, 18);
	data <- loadParams(i);
	data <- data[,index];
	data[data==Inf]<-0;

	print("DEBUG: predicting ... ");
	#require('e1071');
	require('kernlab');
	load('model.rda');
	pred <- predict(svp, data);
	print("DEBUG: predicting ... ");

	if ( (i==50) | (i==70) | (i==90) ) {
		if ( i==50 ) {
			pred50 <- pred;
			save(pred50, file='pred_50.rda');
		} 
		if ( i==70 ) {
			pred70 <- pred;
			save(pred70, file='pred_70.rda');
		} 
		if ( i==90 ) {
			pred90 <- pred;
			save(pred90, file='pred_90.rda');
		} 
	}
	
	print("DEBUG: calculating nr. ones and zeros ... ");
	nr.ones <- sum(as.numeric(as.vector(pred)));
	nr.zeros <- i - nr.ones;

	print("DEBUG: saving ... ");
	output[c,1] <- nr.ones;
	output[c,2] <- nr.zeros;
	c<-c+1
}

write.table(output, file="classification_results.txt", quote=FALSE, row.names=FALSE, col.names=FALSE);
}
predictAll()
