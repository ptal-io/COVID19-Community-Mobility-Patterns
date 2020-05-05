gci <- read.csv('../internalData/GCI4.csv',header=T)
cosine <- read.csv('../internalData/gs_cosine.csv',header=T)
lag <- read.csv('../internalData/gs_lag.csv',header=T, sep=" ")
subregions <- read.csv('../internalData/gs_subregions.csv',header=T, sep=" ")

allmethods <- merge(subregions, gci, 'country', 'country')
allmethods$cosine <- as.numeric(as.character(allmethods$mean))
allmethods$lag <- as.numeric(as.character(allmethods$avg))
allmethods$subregions <- as.numeric(as.character(allmethods$mean))

cnt <-1
c <- colnames(allmethods)
for(i in 2:length(allmethods)) {
	#print(c[i])
	mm <- na.omit(cbind(allmethods$subregions, allmethods[[c[i]]]))
	if (length(mm[,1]) > 10) {
		g <-cor.test(mm[,1], mm[,2], method='kendall')
		tau <- g$estimate[[1]]
		p <- g$p.value
		if (p < 0.01) {
			print(paste(cnt, c[i],tau,p,length(mm[,1]),sep=' - '))
			cnt <- cnt + 1
		}
	}
}


