library(lsa)

cats = c("Grocerypharmacy","Parks","Residential","Retailrecreation","Transitstations","Workplace")

countries <- vector()
dir <- list.files(path='../externalData/GovernmentResponseByCountry/')
cnt <- 1
for(file in dir) {
	aparts <- strsplit(file,'.csv')
	cntry <- aparts[[1]][1]
	countries[cnt] <- cntry
	cnt <- cnt+1
}
ucountries <- unique(countries)


m <- matrix(nrow=length(ucountries), ncol=7)
cnt <- 1
for(cntry in ucountries) {
	
	oxfile = paste("../externalData/GovernmentResponseByCountry/",cntry,".csv",sep="")
	m[cnt,1] <- cntry

	o <- read.csv(oxfile, header=F)
	o[is.na(o)] <- 0
	odates <- o[,1]
	gvals <- o[,2]
	ovals <- o[,4]

	if (length(unique(ovals)) > 1 & length(unique(gvals)) > 1) {
		mm <- na.omit(cbind(ovals, gvals))
		cor = cor.test(mm[,1],mm[,2], method='kendall')
		if (cor$p.value < 0.1)
			m[cnt,2] <- round(cor$estimate, digits=5)
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
newdf$Retailrecreation <- as.numeric(as.character(newdf$Retailrecreation))
newdf$Grocerypharmacy <- as.numeric(as.character(newdf$Grocerypharmacy))
newdf$Transitstations <- as.numeric(as.character(newdf$Transitstations))
newdf$Residential <- as.numeric(as.character(newdf$Residential))
newdf$Workplace <- as.numeric(as.character(newdf$Workplace))
newdf$mean = rowMeans(newdf[,c("Retailrecreation", "Grocerypharmacy","Transitstations","Residential","Workplace")], na.rm=TRUE)
#newdf$median = rowMedians(newdf[,c("Retailrecreation", "Grocerypharmacy","Transitstations","Residential","Workplace")], na.rm=TRUE)
write.table(newdf, '../internalData/gs_cosine_cases3.csv', col.names=TRUE, row.names=FALSE, sep=",")
 
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
write.table(df2, '../internalData/gs_cosine_avgs_cases3.csv', col.names=TRUE, row.names=FALSE)


