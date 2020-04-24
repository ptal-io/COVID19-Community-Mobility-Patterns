library(lsa)

cats = c("grocerypharmacy","parks","residential","retailrecreation","transitstations","workplace")

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


m <- matrix(nrow=length(ucountries), ncol=7)
cnt <- 1
for(cntry in ucountries) {
	
	oxfile = paste("ox/",cntry,".csv",sep="")
	m[cnt,1] <- cntry
	colcnt <-2
	for(cat in cats) {

		googlefile = paste("countries/",cntry,"_",cat,".csv",sep="")
		
		if (file.exists(googlefile) & file.exists(oxfile)) { # & file.exists(afile) & file.exists(bfile)) {
			g <- read.csv(googlefile, header=F)
			gdates <- g[,1]
			gvals <- g[,2] * -1

			if (cat == 'residential')
				gvals <- gvals * -1

			o <- read.csv(oxfile, header=F)
			odates <- o[,1]
			ovals <- o[,2]

			if (!all(is.na(ovals)) & !all(is.na(gvals))) {
				# Correlation
				mm <- na.omit(cbind(ovals, gvals))
				cos <- cosine(mm)[1,2]
				
				m[cnt,colcnt] <- round(cos, digits=5)
			}
		}
		colcnt <- colcnt +1
	}
	cnt <- cnt + 1
}

df <- as.data.frame(m)
colnames(df) <- c(c("country"),cats)

rm <- vector()
cnt <- 1;
for(i in 1:length(df[,1])) {
	if(all(is.na(df[i,2:7]))) {
		rm[cnt] <- i
		cnt <- cnt + 1
	}
}

newdf <- df[-rm,]
row.names(newdf) <- 1:nrow(newdf)
newdf$retailrecreation <- as.numeric(as.character(newdf$retailrecreation))
newdf$grocerypharmacy <- as.numeric(as.character(newdf$grocerypharmacy))
newdf$transitstations <- as.numeric(as.character(newdf$transitstations))
newdf$residential <- as.numeric(as.character(newdf$residential))
newdf$workplace <- as.numeric(as.character(newdf$workplace))
newdf$avg = rowMeans(newdf[,c("retailrecreation", "grocerypharmacy","transitstations","residential","workplace")], na.rm=TRUE)
write.table(newdf, 'gs_cosine.csv', col.names=TRUE, row.names=FALSE, sep=",")
 
avgs <- matrix(nrow=6, ncol=4)
cnt <- 1
for(cat in cats) {
	avgs[cnt,1] <- cat
	avgs[cnt,2] <- round(mean(na.omit(as.numeric(as.character(newdf[[cat]])))), digits=3)
	avgs[cnt,3] <- round(median(na.omit(as.numeric(as.character(newdf[[cat]])))), digits=3)
	avgs[cnt,4] <- round(sd(na.omit(as.numeric(as.character(newdf[[cat]])))), digits=3)
	cnt <- cnt + 1
}
df2 <- as.data.frame(avgs)
colnames(df2) <- c("Category","Mean","Median","Standard deviation")
write.table(df2, 'gs_cosine_avgs.csv', col.names=TRUE, row.names=FALSE)




#m[order(as.numeric(as.character(m[,2]))),]



#ret <- read.csv('countries/LU_residential.csv', header=F)
#plot(ret[,2]*-1, type='l', lwd=2, ylim=range(-100,100))

#res <- read.csv('countries/JP_residential.csv', header=F)
#lines(res[,2]*-1, lwd=2, col='red')

#ox <- read.csv('ox/MN.csv', header=F)
#line	 s(ox[,2], col='blue', lwd=2)

#transfer_entropy(res[,2]*-1,ox[,2])

