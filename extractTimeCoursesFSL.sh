#!/usr/bin/Rscript

#Usage: ./extractTimeCourses <rel. Path to IC files> <number of subjects> <time course length per subject>


source('rfunctions.R');
args<-commandArgs[TRUE];
dat<-read.table(args[1]);
nr.subjects<-args[2];
nr.ICs<-length(dat[,1]);
N<-args[3];
auto.corr<-array(0, dim=c(1, nr.subjects));
entrop<-array(0, dim=c(1, nr.subjects));
dynamic.range <-array(0, dim=c(1, nr.subjects));
ratio<-array(0, dim=c(1, nr.subjects));
output<-array(0, dim=c(nr.ICs, 4));
for ( i in 1:nr.ICs ) {
	for ( j in 1:nr.subjects ) {
		data <- dat[(((j-1)*N)+1):(N*j),i];
		var.snr[j] <- sd(dat)/mean(dat);
		auto.corr<-acf(data,lag.max=1,plot=FALSE,type="correlation");
		one.lag[j]<-auto.corr$acf[1];
		require('entropy');
		entrop[j]<-entropy(data);
		source('rfunctions.R');
		psd<-calcPSD2(data);
		sector<-floor(length(psd[1,])/10)
		LF<-list("x"=psd[1,1:(sector*2)], "y"=psd[2,1:(sector*2)]);
		HF<-list("x"=psd[1,(sector*3):(sector*5)], "y"=psd[2,(sector*3):(sector*5)]);
		dynamic.range[j]<-max(LF$y)-mean(HF$y);
		require('pracma');
		AUC.LF<-trapz(LF$x, LF$y);
		AUC.HF<-trapz(HF$x, HF$y);
		ratio[j]<-AUC.LF/AUC.HF;
	}		
	output[i,1]<-mean(auto.corr);
	output[i,2]<-mean(entrop);
	output[i,3]<-mean(dynamic.range);
	output[i,4]<-mean(ratio);
}
print(output);

