#A collection of R functions useful for Project 2

# R script for loading asci 1d dumps
loadDumps <- function( the_pattern ) {
	theFiles <- list.files( pattern = the_pattern );
	n <- length( theFiles );
	testFile <- read.table( theFiles[1] );
	lengthOfOneFile <- length( testFile[,1] );
	files <- array( 0 , dim = c( lengthOfOneFile , n ) );
	for ( i in 1:n ) {
		aFile <- read.table( theFiles[i] );	
		files[,i] <- aFile[,1];
	}
	return( files );
}

# R loading indices derived from visual inspection
loadTrainingIndex <- function() {
	#return( c(1,1,1,1,0, 1,1,1,1,0, 1,1,1,1,1, 1,1,0,1,0, 1,1,0,0,0, 0,0,0,1,0) );
	return( c(1,1,1,1,1, 1,1,1,1,1, 1,0,1,0,0, 1,0,0,1,1, 1,1,0,0,0, 0,0,0,1,0) );
}

loadTestIndex50 <- function() {
	#return( c(1,1,1,1,0, 1,1,1,1,0, 1,1,1,1,1, 1,1,0,1,0, 1,1,0,0,0, 0,0,0,1,0) );
	return( c(1,1,1,1,1, 0,1,1,1,0, 1,1,0,1,1, 0,1,1,1,1, 0,1,0,1,0, 1,1,1,1,0, 1,0,1,1,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,1,0,0) );
}

loadTestIndex70 <- function() {
	#return( c(1,1,1,1,0, 1,1,1,1,0, 1,1,1,1,1, 1,1,0,1,0, 1,1,0,0,0, 0,0,0,1,0) );
	return( c(1,1,1,0,1, 1,1,0,1,1, 1,1,1,0,1, 0,1,1,1,1, 0,1,1,1,1, 1,1,1,1,1, 1,0,1,0,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,0,1,1, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0) );
}

loadTestIndex90 <- function() {
	#return( c(1,1,1,1,0, 1,1,1,1,0, 1,1,1,1,1, 1,1,0,1,0, 1,1,0,0,0, 0,0,0,1,0) );
	return( c(1,1,0,1,1, 1,1,1,1,1, 1,1,0,1,1, 0,1,0,1,1, 1,1,1,0,1, 1,0,1,1,1, 1,0,0,0,1, 0,0,1,0,1, 1,0,1,1,0, 1,0,0,1,0, 0,0,0,0,0, 1,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0) );
}
# Customized rollmean() function
rollingAverage <- function ( signal , windowSize ) {
	peek <- floor(windowSize/2);
	N <- length(signal);
	signal <- filter(signal, rep(1/windowSize, windowSize), sides=2);
	for(i in 1:peek){
		indices <- c(1:(i+peek));
		signal[i] <- signal[indices]/length(indices);
	}
	for(i in N:(N-peek)){
		indices <- c((i-peek):N);
		signal[i] <- timecourse[indices]/length(indices);
	}
	return(signal);
}
# One method to calculate the PSD for a timecourse
calcPSD <- function ( timecourse , normalize=TRUE , timeaverage=0 , psdaverage=0 ) {
	sig <- timecourse;
	N <- length(timecourse);
	if(timeaverage > 0) {
		sig <- rollingAveraget(timecourse, timeaverage);
	}
	fourier <- fft( timecourse );
	power <- ( Mod(fourier) )^2;
	power_firsthalf <- power[1:(N/2)];
	if(normalize==TRUE){
		# normalization constant according to Venables & Ripley
		# Listed as source on ?spec.pgram 
		T <- sqrt(sum(timecourse^2))*length(timecourse);
		power_firsthalf <- power_firsthalf/T;	
	}
	if(psdaverage > 0){
		power_firsthalf <- rollingAverage(power_firsthalf, psdaverage);
	}
	xaxis <- 1:(N/2)/N;	
	answer <- array( 0, dim=c(2,N/2) );
	answer[1,]<-xaxis;
	answer[2,]<-power_firsthalf;
	return(answer);
}
# Another method of calculating the PSD using autocorrelations
calcPSD2 <- function ( timecourse , normalize=TRUE , psdaverage=0 ) {
	sig <- timecourse;
	N <- length(timecourse);
	auto_corr <- acf(sig, lag.max=N, plot=FALSE);
	power <- Mod( fft(auto_corr) );
	power_firsthalf <- power[1:(N/2)];
	if(normalize==TRUE){
		# empiric normalization?
		power_firsthalf <- power_firsthalf/(N/2);
	}
	if(psdaverage > 0){
		power_firsthalf <- rollingAverage(power_firsthalf, psdaverage);
	}
	xaxis <- 1:(N/2)/N;
	answer <- array( 0, dim=c(2,N/2) );
	answer[1,]<-xaxis;
	answer[2,]<-power_firsthalf;
	return(answer);
}
# Test function to see how well a dataset (input: asci dump) fits with
# a normal approximation
plotFitToNormal <- function ( x ) {
	h <- hist( x, breaks="FD" , plot=FALSE );
        xhist <- c( min(h$breaks), h$breaks );
	yhist <- c( 0, h$density, 0);
	xfit <- seq( min(x), max(x), length=40 );
	yfit <- dnorm( xfit, mean=mean(x), sd=sd(x) );
	plot( xhist, yhist, type="s", ylim=c(0, max(yhist,yfit)), xlab="t-values", ylab="normalized probability");
	lines( xfit, yfit, col="red" );
	ks.test(yhist,yfit);
	test.results <- ks.test(yhist,yfit);
	
	return( c(test.results$statistic, test.results$p.value) );
}
# Test function to see how well a dataset (input: asci dump) fits with
# a gamma distribution
# requries (MASS)
plotFitToGamma <- function ( x ) {
	require(MASS);
	Y<-fitdistr( x , "gamma" );
	theShape<-Y$estimate[1];
	theRate<-Y$estimate[2];
	h <- hist( x, breaks="FD", plot=FALSE );
	xhist <- c( min(h$breaks), h$breaks );
	yhist <- c( 0, h$density, 0);
	xfit <- seq( min(x), max(x), length=40 );
	yfit <- dgamma( xfit, shape=theShape, rate=theRate );
	plot( xhist, yhist, type="s", ylim=c(0, max(yhist,yfit)), xlab="t-values", ylab="normalized probability" );
	lines( xfit, yfit, col="red" );
	ks.test(yhist,yfit);
	test.results <- ks.test(yhist,yfit);
	return( c(test.results$statistic, test.results$p.value) );
}
# Calculates threshold given normal approximation
calcClusterThresh <- function ( input_data ) {
	data <- input_data[input_data != 0];
        pos_thresh <- mean(data) + 2*sd(data);
	neg_thresh <- mean(data) - 2*sd(data);
	return( c(pos_thresh, neg_thresh) );
}
# Calculates accuracy of prediction
calcAccuracy <- function ( tp, tn, fp, fn, n) {
	H.1 <- -(tp/n)*log2(tp/n);
	if(is.nan(H.1)) H.1 <- 0;
	H.2 <- -(tn/n)*log2(tn/n);
	if(is.nan(H.2)) H.2 <- 0;
	H.3 <- -(fp/n)*log2(fp/n);
	if(is.nan(H.3)) H.3 <- 0;
	H.4 <- -(fn/n)*log2(fn/n); 
	if(is.nan(H.4)) H.4 <- 0;
	H <- H.1 + H.2 + H.3 + H.4;
	I.1 <- -(tp/n)*log2(((tp+fp)/n)*((tp+fn)/n));
	if(is.nan(I.1)) I.1 <- 0;
	I.2 <- -(fn/n)*log2(((tp+fn)/n)*((tn+fn)/n));
	if(is.nan(I.2)) I.2 <- 0;
	I.3 <- -(fp/n)*log2(((tp+fp)/n)*((tn+fp)/n));
	if(is.nan(I.3)) I.3 <- 0;
	I.4 <- -(tn/n)*log2(((tn+fn)/n)*((tn+fp)/n)); 	
	if(is.nan(I.4)) I.4 <- 0;
	I <- -H + I.1 + I.2 + I.3 + I.4;
	HD <- -((tp+fn)/n)*log2((tp+fn)/n)-((tn+fp)/n)*log2((tn+fp)/n);
	IC <- I / HD
	return( c(H,I,HD,IC) ); 
}
# Plot accuracy
plotAccuracy <- function(data, classes, minCost, maxCost, the.kernel) {
	plotAcc <- array(0, length(seq(minCost,maxCost,10)));
	c <- 1;
	for( i in seq(minCost, maxCost, 10)) {
	model <- svm(data, classes, type='C', cost=i, kernel=the.kernel);
	prediction <- predict(model, training.params);
	tp <- table(prediction,indices)[1];
	tn <- table(prediction,indices)[4];
	fp <- table(prediction,indices)[2];
	fn <- table(prediction,indices)[3];
	n <- length(prediction);
	acc <- calcAccuracy(tp,tn,fp,fn,n);
	print(acc);	
	plotAcc[c] <- acc[2];  
	c <- c+1;
	}
	plot(seq(minCost,maxCost,10), plotAcc, type='l')
}
loadParams <- function( nr , scale=0) {
	mod1 <- read.table(paste0("mod1_params_",toString(nr)));
	mod2 <- read.table(paste0("mod2_params_",toString(nr)));
	mod3 <- read.table(paste0("mod3_params_",toString(nr)));
	mod4 <- read.table(paste0("mod4_params_",toString(nr)));
	mod5 <- read.table(paste0("mod5_params_",toString(nr)));	
	output <- array(0, dim=c(nr, 18));
	output[, 1] <- mod1[, 1];
	output[, 2] <- mod1[, 2];
	output[, 3] <- mod2[, 2];
	output[, 4] <- mod2[, 3];
	output[, 5] <- mod2[, 4];
	output[, 6] <- mod2[, 5];
	output[, 7] <- mod3[, 2];
	output[, 8] <- mod3[, 3];
	output[, 9] <- mod3[, 4];
	output[, 10] <- mod3[, 5];
	output[, 11] <- mod3[, 6];
	output[, 12] <- mod4[, 2];
	output[, 13] <- mod4[, 3];
	output[, 14] <- mod4[, 4];
	output[, 15] <- mod5[, 1];
	output[, 16] <- mod5[, 2];
	output[, 17] <- mod5[, 3];
	output[, 18] <- mod5[, 4];
	if( scale == 1 ){
		for(i in 1:18){
			output[, i] <- mynorm(output[, i]);
		}
	}
	output[output==Inf] <- 0;
	return( output );
}
classifierSelection <- function(classes, data) {
	model <- glm(classes~data[,1]+data[,2]+data[,4]+data[,5]+data[,6]+data[,7]+data[,8]+data[,9]+data[,10]+data[,11]+data[,12]+data[,13]+data[,14]+data[,15]+data[,16]+data[,17]+data[,18]);
	return( model );
}
classifierSelection2 <- function(classes, data) {
	for (i in 1:18 ) {
		paste0("model",toString(i)) <- glm(classes~data[,i]);
	}
	return.object <- list(model1, model2, model3, model4, model5, model6, model7, model8, model9, model10, model11, model12, model13, model14, model15, model16, model17, model18);
	return( return.object );
}
mynorm <- function ( data ) {
	output <- data/max(data);
	return( output )
}
