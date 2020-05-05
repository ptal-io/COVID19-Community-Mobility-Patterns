population <- read.csv('../externalData/population.csv',header=T)
cosine <- read.csv('../internalData/gs_cosine.csv',header=T)
subregions <- read.csv('../internalData/gs_subregions.csv',header=T, sep=" ")
lag <- read.csv('../internalData/gs_lag.csv',header=T, sep=" ")

allmethods <- merge(subregions, population, by.x='country', by.y='code')
allmethods$cosine <- as.numeric(as.character(allmethods$mean))
allmethods$subregions <- as.numeric(as.character(allmethods$mean))
allmethods$lag <- as.numeric(as.character(allmethods$avg))

mm <- na.omit(cbind(allmethods$subregions, allmethods$area))
g <-cor.test(mm[,1], mm[,2], method='kendall')
print(paste(g$estimate[[1]], g$p.value, sep=' - '))

