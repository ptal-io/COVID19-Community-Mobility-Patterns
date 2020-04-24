
pdf("countries.pdf", width=60, height=40)
par( mar = c(4,4,2,0), mfrow=c(10,13))

cats = c("grocerypharmacy","parks","residential","retailrecreation","transitstations","workplace")
cols = c('#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#ffff33','#a65628','#f781bf','#999999');

countries <- vector()
dir <- list.files(path='countries/')
cnt <- 1
for(file in dir) {
	aparts <- strsplit(file,'_')
	cntry <- aparts[[1]][1]
	countries[cnt] <- cntry
	cnt <- cnt+1
}
ucountries <- unique(countries)

for(cntry in ucountries) {
	cnt <- 1
	ofile = paste("ox/",cntry,".csv",sep="")
	#afile = paste("apple/",cntry,"_driving.csv",sep="")
	#bfile = paste("apple/",cntry,"_walking.csv",sep="")
	for(cat in cats) {
		sfile = paste("countries/",cntry,"_",cat,".csv",sep="")
		
		if (file.exists(sfile) & file.exists(ofile)) { # & file.exists(afile) & file.exists(bfile)) {
			s <- read.csv(sfile, header=F)
			dates <- s[,1]
			vals <- s[,2]

			o <- read.csv(ofile, header=F)
			odates <- o[,1]
			ovals <- o[,2]

			#a <- read.csv(afile, header=F)
			#avals <- a[,1]

			#b <- read.csv(bfile, header=F)
			#bvals <- b[,1]

			if (cnt == 1) {
				plot(vals, type='n', xlab="Dates", ylab="Percentage change from baseline", xaxt='n', cex.lab=1.2, cex=3, main=cntry, ylim=range(100,-100))
				axis(1, seq(1,length(dates),7), as.vector(dates[seq(1,length(dates),7)]), tick = TRUE, cex.axis=1.1)
				grid()
				lines(ovals[1:length(vals)],lwd=3,col='black')
				#lines(avals[1:length(vals)],lwd=2,col='black', lty='longdash')
				#lines(bvals[1:length(vals)],lwd=2,col='blue', lty='longdash')
			}
			lines(vals, lwd=2, col=cols[cnt])
			cnt <- cnt + 1
			#min <- min(length(ovals),length(vals))
			#cor = cor(ovals[1:min], vals[1:min])
			#name = paste(cntry, cat, cor, sep=' - ')
			#print(name)
		}
	}
}

dev.off() 

