#!/usr/bin/env Rscript
args<-commandArgs(TRUE);
dump<-read.table(args[1]);
data<-dump[dump!=0];
print( c(mean(data)+2*sd(data),-1*(mean(data)-2*sd(data))) );
