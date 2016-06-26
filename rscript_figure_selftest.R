#rscript to generate the figure 3d projection of the model onto the training data (self-test)

#this script is designed to run from the workspace "classifier_selection_workspace.RDat"
#instructions:
#open R -> load workspace -> source this file -> exit WITHOUT saving the workspace!!!

# loading libraries
library(e1071);
library(rgl);
library(misc3d);

indices <- training_classes;
training.params <- training_params;

# loading data
group <- indices
dat <- data.frame(group=factor(indices), X1=training.params[,1], X2=training.params[,2], X3=training.params[,3]);
fit = svm(group ~ ., data=dat);

n <- length(training.params[,1]);
nnew <- 50;

# Plot original data
plot3d(dat$X1[which(dat$group==0)], dat$X2[which(dat$group==0)], dat$X3[which(dat$group==0)], col='red', size=5, pch=22, xlab="cg.plus", ylab="peak", zlab="bb.fill");
points3d(dat$X1[which(dat$group==1)], dat$X2[which(dat$group==1)], dat$X3[which(dat$group==1)], col='blue', size=10, pch=".");

# Get decision values for a new data grid
newdat.list = lapply(dat[,-1], function(x) seq(min(x), max(x), len=nnew));
newdat      = expand.grid(newdat.list);
newdat.pred = predict(fit, newdata=newdat, decision.values=T);
newdat.dv   = attr(newdat.pred, 'decision.values');
newdat.dv   = array(newdat.dv, dim=rep(nnew, 3));

# Fit/plot an isosurface to the decision boundary
contour3d(newdat.dv, level=0, x=newdat.list$X1, y=newdat.list$X2, z=newdat.list$X3, add=T);

