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
	
	m[cnt,1] <- cntry
	colcnt <-2
	for(cat in cats) {

		googlefile = paste("../externalData/MobilityByCountry/",cntry,"_",cat,".csv",sep="")

		mycos <- vector()
		mycoscnt <- 1
		
		if (file.exists(googlefile)) { # & file.exists(afile) & file.exists(bfile)) {
			g <- read.csv(googlefile, header=T)
			provcnt <- 2;
			gdates <- g[,1]
			for(i in 2:length(g)) {
				gvals1 <- g[,i]
				for(j in provcnt:length(g)) {
					gvals2 <- g[,j]
					if (names(g)[i] != names(g)[j] & names(g)[i] != cntry & names(g)[j] != cntry) {
						if (length(unique(gvals1)) > 1 & length(unique(gvals2)) > 1) {
							mm <- na.omit(cbind(gvals1, gvals2))
							cos <- cosine(mm)[1,2]
							#print(paste(names(g)[i], names(g)[j], cos, sep=' - '))
							mycos[mycoscnt] <- cos
							mycoscnt <- mycoscnt + 1
						}
					}
				}
				provcnt <- provcnt + 1
			}
		}
		m[cnt,colcnt] <- sd(na.omit(mycos))
		colcnt <- colcnt +1
	}
	cnt <- cnt + 1
}

df <- as.data.frame(m)
colnames(df) <- c(c("country"),cats)

rm <- vector()
cnt <- 1
for(i in 1:length(df[,1])) {
	if(length(unique(as.numeric(df[i,2:7]))) == 1) {
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
newdf$Parks <- as.numeric(as.character(newdf$Parks))
newdf$mean = rowMeans(newdf[,c("Parks", "Retailrecreation", "Grocerypharmacy","Transitstations","Residential","Workplace")], na.rm=TRUE)
write.table(newdf, '../internalData/gs_subregions.csv', col.names=TRUE, row.names=FALSE)



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
write.table(df2, '../internalData/gs_subregions_avg.csv', col.names=TRUE, row.names=FALSE)




#m[order(as.numeric(as.character(m[,2]))),]



#ret <- read.csv('countries/LU_residential.csv', header=F)
#plot(ret[,2]*-1, type='l', lwd=2, ylim=range(-100,100))

#res <- read.csv('countries/JP_residential.csv', header=F)
#lines(res[,2]*-1, lwd=2, col='red')

#ox <- read.csv('ox/MN.csv', header=F)
#line	 s(ox[,2], col='blue', lwd=2)

#transfer_entropy(res[,2]*-1,ox[,2])