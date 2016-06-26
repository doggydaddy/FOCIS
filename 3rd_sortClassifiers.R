#!/usr/bin/Rscript

mod1.params <- read.table('mod1_params');
mod3.params <- read.table('mod3_params');
mod5.params <- read.table('mod5_params');
feat.1 <- mod1.params[,1];
feat.2 <- mod3.params[,2];
feat.3 <- mod3.params[,6];
feat.4 <- mod5.params[,1];
feat.5 <- mod5.params[,4];
print( cbind(feat.1, feat.2, feat.3, feat.4, feat.5) );


