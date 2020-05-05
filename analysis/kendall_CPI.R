library(countrycode)


cpi <- read.csv('../externalData/CPI2018.csv',header=T)
cpi$cntry <- countrycode(cpi$country, origin = 'iso3c', destination = 'iso2c')


cosine <- read.csv('../internalData/gs_cosine.csv',header=T)
lag <- read.csv('../internalData/gs_lag.csv',header=T, sep=" ")
subregions <- read.csv('../internalData/gs_subregions.csv',header=T, sep=" ")
population <- read.csv('../externalData/population.csv',header=T)

allmethods <- merge(subregions, cpi, by.x='country', by.y='cntry')

allmethods$cosine <- as.numeric(as.character(allmethods$mean))
allmethods$lag <- as.numeric(as.character(allmethods$avg))
allmethods$subregions <- as.numeric(as.character(allmethods$mean))


mm <- na.omit(cbind(allmethods$subregions, allmethods$CPI))
g <- cor.test(mm[,1], mm[,2], method='kendall')
print(paste(g$estimate[[1]], g$p.value, sep=' - '))