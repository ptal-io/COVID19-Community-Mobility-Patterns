grid <- read.csv('../externalData/GRID2.csv',header=T)
cosine <- read.csv('../internalData/gs_cosine.csv',header=T)

allmethods <- merge(cosine, grid, by.x='country', by.y='Country')
allmethods$cosine <- as.numeric(as.character(allmethods$mean))


m <- vector()
cnt <- 1
for (i in 1:length(allmethods$CPI.Rank)) {
	rand <- runif(1, 0, 1.0)/1000
	x <- allmethods$CPI.Rank[i] + rand
	m[i] <- x
	cnt <- cnt + 1
}

mm <- na.omit(cbind(allmethods$cosine, m*-1))
cor.test(mm[,1], mm[,2], method='kendall')