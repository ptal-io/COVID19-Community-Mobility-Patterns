library(reshape2)
library(countrycode)

data <- read.csv('../internalData/gs_subregions.csv', header=T, sep=' ')
data <- na.omit(data)


#for(i in 2:length(data)) {
#	a <- max(data[,i])
#	b <- min(data[,i])
#	data[,i] <- (data[,i] - b) / (a - b)
#}

pop <- read.csv('../externalData/population.csv',header=T)
pop$continent <- as.character(pop$continent)
pop$code <- as.character(pop$code)
pop$continent[is.na(pop$continent)] <- "NA"
pop$code[is.na(pop$code)] <- "NA"


data <- na.omit(data)
rownames(data) <- data$country
#rownames(data) <- countrycode(row.names(data), origin = 'iso2c', destination = 'country.name')
data$country = NULL
data$mean.x = NULL
data$mean = NULL
data$country.y = NULL

d <- dist(data)
df <- melt(as.matrix(d), varnames = c("g1name", "g2name"))

df2 <- merge(df, pop, by.x='g1name', by.y='code')
df2$area = NULL
df2$population = NULL
df2$country = NULL
df2$c1name <- df2$continent
df2$continent = NULL

df2 <- merge(df2, pop, by.x='g2name', by.y='code')
df2$area = NULL
df2$population = NULL
df2$country = NULL
df2$c2name <- df2$continent
df2$continent = NULL

conts <- c("AS","AF","EU", "NA","OC","SA")

m <- matrix(nrow=6, ncol=2)

cnt <- 1
for(i in 1:length(conts)) {
	m[cnt,1] <- conts[i]
	mn <- round(mean(df2[(df2$c1name == df2$c2name & df2$c2name == conts[i] & df2$g2name != df2$g1name),]$value),3)
	md <- round(median(df2[(df2$c1name == df2$c2name & df2$c2name == conts[i] & df2$g2name != df2$g1name),]$value),3)
	m[cnt,2] <- paste(mn,' (',md,')',sep='')
	cnt <- cnt + 1
}

round(mean(df2[(df2$c1name == df2$c2name & df2$g2name != df2$g1name),]$value),3)
round(median(df2[(df2$c1name == df2$c2name & df2$g2name != df2$g1name),]$value),3)

round(mean(df2[(df2$c1name != df2$c2name & df2$g2name != df2$g1name),]$value),3)
round(median(df2[(df2$c1name != df2$c2name & df2$g2name != df2$g1name),]$value),3)