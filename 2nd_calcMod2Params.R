#!/usr/bin/Rscript

#This R script caluclates mod2 params (timecourses)
#FOR ONE SUBJECT
#and prints it out to tmp_mod2_params_$dat (see 1st_mod2.sh)

args<-commandArgs(TRUE);
inputData<-args[1];
data<-read.table(inputData);
data<-as.double(array(data[-1,3]));

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
print(c(one.lag, entrop, dynamic.range, ratio));

