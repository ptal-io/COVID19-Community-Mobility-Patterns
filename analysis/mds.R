library(countrycode)
library(ggplot)
library(ggrepel)


cos <- read.csv('../internalData/gs_cosine.csv', header=T)
lag <- read.csv('../internalData/gs_lag.csv', header=T, sep=' ')

#cats <- c("grocerypharmacy", "parks", "residential", "retailrecreation", "transitstations","workplace")
lag <- na.omit(lag)

for(i in 2:length(lag)) {
	a <- max(lag[,i])
	b <- min(lag[,i])
	lag[,i] <- (lag[,i] - b) / (a - b)
}

#sub <- read.csv('../internalData/gs_subregions.csv', header=T, sep=' ')
pop <- read.csv('../externalData/population.csv',header=T)
pop$continent <- as.character(pop$continent)
pop$continent[is.na(pop$continent)] <- "NB"

#data <- cos
data <- merge(cos, lag, by.x='country', by.y='country')
#data <- merge(a, pop, by.x='country', by.y='code')

data <- na.omit(data)
rownames(data) <- data$country
#data[rownames(data) == 'KR',] <- NA
#data[rownames(data) == 'TW',] <- NA
#data[rownames(data) == 'JP',] <- NA
#data <- na.omit(data)

colors <- merge(data, pop, by.x='country', by.y='code')

data$country = NULL
data$mean.x = NULL
data$avg = NULL
data$mean = NULL




# SET COLORS BASED ON CONTINENTS
tt <- data.frame(country = as.character(colors$country), continent= as.character(colors$continent), color=NA)
tt$color[tt$continent == 'AF'] <- "#1b9e77"
tt$color[tt$continent == 'AS'] <- "#d95f02"
tt$color[tt$continent == 'EU'] <- "#7570b3"
tt$color[tt$continent == 'NB'] <- "#e7298a"
tt$color[tt$continent == 'OC'] <- "#66a61e"
tt$color[tt$continent == 'SA'] <- "#e6ab02"

tt$continent <- as.character(tt$continent)
tt$continent[tt$continent == 'AF'] <- "Africa"
tt$continent[tt$continent == 'AS'] <- "Asia"
tt$continent[tt$continent == 'EU'] <- "Europe"
tt$continent[tt$continent == 'NB'] <- "North America"
tt$continent[tt$continent == 'OC'] <- "Oceania"
tt$continent[tt$continent == 'SA'] <- "South America"

cntrynames <- countrycode(row.names(data), origin = 'iso2c', destination = 'iso3c')
rownames(data) <- cntrynames

d <- dist(data)
fit <- cmdscale(d, eig=TRUE, k=2)
x <- fit$points[,1]
y <- fit$points[,2]
z <- rownames(data)
#plot(x, y, xlab="Coordinate 1", ylab="Coordinate 2", main="Metric MDS", pch=20)
#text(x, y, labels = cntrynames, cex=1)


g <- data.frame(cbind(x,y))
rownames(g) <- cntrynames

Continent <- cbind(tt$continent, tt$color)

#ccc <- unique(cbind(tt$continent, tt$color))

#ccc[ccc[,1] == 'Africa',2] <- "#66a61e"
#ccc[ccc[,1] == 'Oceania',2] <- "#1b9e77"

p <- ggplot(g, aes(x, y, label = rownames(g), pointtype="T999", color=Continent[,1])) +
	geom_text_repel() +
	geom_point(size=2, shape=19) +
	#scale_color_manual(labels = ccc[,1], values = ccc[,2]) +
	theme_classic() + 
	labs(title = "", x = "Coordinate 1", y = "Coordinate 2", color = "Continent") + 
	#theme(legend.position="bottom", legend.box = "horizontal") + 
	theme(legend.title=element_text(size=15),  legend.text=element_text(size=12)) 




pdf("../plots/mds_sub.pdf", width=12, height=8)
par( mar = c(4,4,2,0))
p
dev.off()