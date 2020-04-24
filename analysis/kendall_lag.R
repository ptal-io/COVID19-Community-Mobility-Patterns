pearson <- read.csv('gs_cor.csv',header=T)
cosine <- read.csv('gs_cosine.csv',header=T)
frechet <- read.csv('gs_hausdorff.csv',header=T, sep=' ')

a <- merge(pearson, cosine, 'country', 'country')
b <- merge(a, frechet, 'country', 'country')
allmethods <- b[,c("country", "avg.x", "avg.y", "avg")]

allmethods$pearson <- as.numeric(as.character(allmethods$avg.x))
allmethods$cosine <- as.numeric(as.character(allmethods$avg.y))
allmethods$avg = rowMeans(allmethods[,c("pearson", "cosine")], na.rm=TRUE)

cor.test(allmethods[,2], allmethods[,3], method='kendall')

allmethods <- na.omit(allmethods)

m <- matrix(nrow=140, ncol=3)
mcnt <- 1

pop <- read.csv('population.csv',header=T, sep='\t')
death <- read.csv('deaths.csv',header=T, sep=',')
#avg <- read.csv('forkendall.csv',header=T, sep=',')

ocnt <- 1
for(pp in pop$code) {
	oocnt <- 1
	for(p in death$country) {
		icnt <-1
		for(d in allmethods$country) {
			#print(paste(d,p,sep='-'))
			if(p == d & p == pp) {
				m[mcnt, 1] <- d
				m[mcnt, 2] <- death$deaths[oocnt]
				m[mcnt, 3] <- allmethods$cosine[icnt]
				mcnt <- mcnt + 1
			}
			icnt <- icnt + 1
		}
		oocnt <- oocnt + 1
	}
	ocnt <- ocnt + 1
}

dd <- as.data.frame(m)
dd <- na.omit(dd)
cor.test(as.numeric(as.character(dd[,2])), as.numeric(as.character(dd[,3])), method='kendall')