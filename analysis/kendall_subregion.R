library("rjson")
result <- fromJSON(file = "input.json")

provs <- read.csv('gs_provs.csv',header=T, sep=' ')
cosine <- read.csv('gs_cosine.csv',header=T, sep=',')
gdp <- read.csv('GDP.csv',header=T, sep=',')
df <- data.frame(country=character(),gdp=integer(),stringsAsFactors=F) 
for(i in 1:length(gdp$Country.Code)) {
	for(j in 1:length(result)) {
		if (as.character(result[j]) == as.character(gdp$Country.Code[i])) {
			#gdp$Country.Code[i] <- "test"
			df[i,1] <- as.character(names(result[j]))
			df[i,2] <- gdp$GDP2018[i]
		}
	}
}

rm <- vector()
cnt <- 1;
for(i in 1:length(df[,1])) {
	if(all(is.na(df[i,2]))) {
		rm[cnt] <- i
		cnt <- cnt + 1
	}
}

newdf <- df[-rm,]
row.names(newdf) <- 1:nrow(newdf)

a <- merge(provs, cosine, 'country', 'country')
b <- merge(a, newdf, 'country', 'country')
allmethods <- b[,c("country", "avg.x", "avg.y","gdp")]

allmethods$provs <- as.numeric(as.character(allmethods$avg.x))
allmethods$cosine <- as.numeric(as.character(allmethods$avg.y))
allmethods$gdp <- as.numeric(as.character(allmethods$gdp))

cor.test(allmethods$provs, allmethods$gdp, method='kendall')

allmethods <- na.omit(allmethods)

