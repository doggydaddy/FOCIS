#!/usr/bin/env Rscript

# This script is meant to be run after the shell script
# Acts on the dumps and calculates, using R white matter
# grey matter and csf tissueprior weighted contributions
# as classification parameters

# Does not require rfunctions.R source files

# bringing up the file lists
after.pos.dump <- list.files(pattern='DUMP_POS_MASK*');
after.neg.dump <- list.files(pattern='DUMP_NEG_MASK*');
before.dump <- list.files(pattern='DUMP_BEFORE*');
N <- length(after.pos.dump);

results <- array( 0 , dim=c(N,2) );

for (i in 1:N) {
	pos.masked <- read.table(after.pos.dump[i]);
	neg.masked <- read.table(after.neg.dump[i]);
	A_before <- read.table(before.dump[i]);
	T <- sum(A_before[,1]);
	pos.contrib <- sum(pos.masked[,1])/T;
	neg.contrib <- sum(neg.masked[,1])/T;
	results[i,1] <- pos.contrib;
	results[i,2] <- neg.contrib;
}
write.table(results, file='mod1_params');
