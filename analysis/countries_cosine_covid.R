library(lsa)

cats = c("Grocerypharmacy","Parks","Residential","Retailrecreation","Transitstations","Workplace")

countries <- vector()
dir <- list.files(path='../externalData/MobilityByCountry/')
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
	
	oxfile = paste("../externalData/GovernmentResponseByCountry/",cntry,".csv",sep="")
	m[cnt,1] <- cntry
	colcnt <-2
	for(cat in cats) {

		googlefile = paste("../externalData/MobilityByCountry/",cntry,"_",cat,".csv",sep="")
		
		if (file.exists(googlefile) & file.exists(oxfile)) { # & file.exists(afile) & file.exists(bfile)) {
			g <- read.csv(googlefile, header=T)
			gdates <- g[,1]
			gvals <- g[,2] * -1

			if (cat == 'Residential')
				gvals <- gvals * -1

			o <- read.csv(oxfile, header=F)
			o[is.na(o)] <- 0
			odates <- o[,1]
			ovals <- o[,3]
				
			if (length(unique(ovals)) > 1 & length(unique(gvals)) > 1) {
				# Correlation
				mm <- na.omit(cbind(ovals, gvals))
				cor = cor.test(mm[,1],mm[,2], method='kendall')
				#cos <- cosine(mm)[1,2]
				if (cor$p.value < 0.1)
					m[cnt,colcnt] <- round(cor$estimate, digits=5)
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
newdf$Retailrecreation <- as.numeric(as.character(newdf$Retailrecreation))
newdf$Grocerypharmacy <- as.numeric(as.character(newdf$Grocerypharmacy))
newdf$Transitstations <- as.numeric(as.character(newdf$Transitstations))
newdf$Residential <- as.numeric(as.character(newdf$Residential))
newdf$Workplace <- as.numeric(as.character(newdf$Workplace))
newdf$mean = rowMeans(newdf[,c("Retailrecreation", "Grocerypharmacy","Transitstations","Residential","Workplace")], na.rm=TRUE)
#newdf$median = rowMedians(newdf[,c("Retailrecreation", "Grocerypharmacy","Transitstations","Residential","Workplace")], na.rm=TRUE)
write.table(newdf, '../internalData/gs_cosine_cases.csv', col.names=TRUE, row.names=FALSE, sep=",")
 
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
write.table(df2, '../internalData/gs_cosine_avgs_cases.csv', col.names=TRUE, row.names=FALSE)


