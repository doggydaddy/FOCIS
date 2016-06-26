#!/usr/bin/Rscript

#This R script calculates mod4 params (density plot)
#and prints it out the mod4_params (see 1st_mod4.sh)

args<-commandArgs(TRUE);
inputData<-args[1];
data<-read.table(inputData);
require(entropy);
require(e1071);
dens<-density(data[,1]);
kurt<-kurtosis(dens$y);
skew<-skewness(dens$y);
spat.entropy<-entropy(dens$y);
print(c(kurt, skew, spat.entropy));
