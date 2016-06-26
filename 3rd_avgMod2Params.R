#!/usr/bin/Rscript

args<-commandArgs(TRUE);
data<-read.table(args[1]);

one.lag <- mean(data[,2]);
entrop <- mean(data[,3]);
dynamic.range <- mean(data[,4]);
ratio <- mean(data[,5]);

print( c(one.lag, entrop, dynamic.range, ratio) );
