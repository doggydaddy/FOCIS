#Script to generate figure: classifier plots

#Works in R environment with workspace "classifier_selection_workspace.Rdat" loaded.

par( mfrow=c(2,2) );

plot(cg.plus, peak, col=0, pch=22, main="cg.plus vs peak");
points(cg.plus[training_classes==0], peak[training_classes==0], col=2, pch =0);
points(cg.plus[training_classes==1], peak[training_classes==1], col=3, pch =6);

plot(cg.plus, ic.ratio, col=0, pch=22, main="cg.plus vs ic.ratio");
points(cg.plus[training_classes==0], ic.ratio[training_classes==0], col=2, pch =0);
points(cg.plus[training_classes==1], ic.ratio[training_classes==1], col=3, pch =6);

plot(peak, ic.ratio, col=0, pch=22, main="peak vs ic.ratio");
points(peak[training_classes==0], ic.ratio[training_classes==0], col=2, pch =0);
points(peak[training_classes==1], ic.ratio[training_classes==1], col=3, pch =6);

library(scatterplot3d);
sp3d<-scatterplot3d(cg.plus, peak, ic.ratio, pch='.', main="All 3 chosen classification parameters");
sp3d$points3d(cg.plus[training_classes==0], peak[training_classes==0], ic.ratio[training_classes==0], col=2, pch=0);
sp3d$points3d(cg.plus[training_classes==1], peak[training_classes==1], ic.ratio[training_classes==1], col=3, pch=6);
