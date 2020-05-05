pearson <- read.csv('../internalData/gs_pearson.csv',header=T)
cosine <- read.csv('../internalData/gs_cosine.csv',header=T)

a <- merge(pearson, cosine, 'country', 'country')
allmethods <- a[,c("country", "mean.x", "mean.y")]

allmethods$pearson <- as.numeric(as.character(allmethods$mean.x))
allmethods$cosine <- as.numeric(as.character(allmethods$mean.y))
allmethods$avg = rowMeans(allmethods[,c("pearson", "cosine")], na.rm=TRUE)

cor.test(allmethods$cosine, allmethods$pearson, method='kendall')

