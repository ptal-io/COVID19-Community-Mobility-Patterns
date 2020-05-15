library(countrycode)

data <- read.csv('../internalData/gs_lag.csv', header=T, sep=' ')
data <- na.omit(data)
rownames(data) <- data$country
rownames(data) <- countrycode(row.names(data), origin = 'iso2c', destination = 'country.name')
data$country = NULL
data$mean.x = NULL
data$avg = NULL
data$mean = NULL


d <- dist(data)