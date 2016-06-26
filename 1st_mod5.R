#!/usr/bin/Rscript

alldata <- read.table('melodic_mix');
nrComponents <- dim(alldata)[2];
output <- array(0, dim=c(nrComponents,4));
for ( i in 1:nrComponents ) {
	data <- alldata[,i];

	#Copied from 2nd_calcMod2Params.R	
	cor<-acf(data, type="correlation", lag.max=1, plot=FALSE);
	one.lag <- cor$acf[2];
	require(entropy);

	require(stats);
	#Izenman, 1991
	#    Izenman, A. J. 1991.
	#    Recent developments in nonparametric density estimation.
	#    Journal of the American Statistical Association, 86(413):205-224. 
	W <-2 * IQR(data) * length(data)^(-1/3);
	nrBins <- ceiling( (range(data)[2] - range(data)[1] ) / W )

	entrop <- entropy(discretize(data,nrBins));

	source('~/SVM_framework/rfunctions.R');
	psd<-calcPSD(data);
	sector<-floor(length(psd[1,])/10)
	LF<-list("x"=psd[1,1:(sector*2)], "y"=psd[2,1:(sector*2)]);
	HF<-list("x"=psd[1,(sector*3):(sector*5)], "y"=psd[2,(sector*3):(sector*5)]);
	dynamic.range<-max(LF$y)-mean(HF$y);
	require('pracma');
	AUC.LF<-trapz(LF$x, LF$y);
	AUC.HF<-trapz(HF$x, HF$y);
	ratio<-AUC.LF/AUC.HF;
	output[i,1] <- one.lag;
	output[i,2] <- entrop;
	output[i,3] <- dynamic.range;
	output[i,4] <- ratio;
}
write.table(output, file="mod5_params", quote=FALSE, col.names=FALSE, row.names=FALSE);
