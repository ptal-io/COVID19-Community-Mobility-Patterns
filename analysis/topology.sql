

create table tmp as SELECT g1.gid As gid1, g2.gid As gid2, ST_DistanceSphere(g1.geom, g2.geom) as dist
    FROM countries As g1, countries As g2   
WHERE g1.gid <> g2.gid;

alter table tmp add column g1name varchar(3), add column g2name varchar(3);
update tmp set g1name = a.adm0_a3 from countries a where a.gid = gid1;
update tmp set g2name = a.adm0_a3 from countries a where a.gid = gid2;

select * from tmp order by g1name, dist asc limit 10;

library(reshape2)
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
df <- melt(as.matrix(d), varnames = c("g1name", "g2name"))
write.table(df, file="../internalData/subregions_dist.csv", row.names=FALSE, sep=',')

create table subregions as select * from dist limit 0;
copy subregions from '/home/grantmckenzie/Documents/COVID19-CommunityMobilityPatterns/internalData/subregions_dist.csv' with csv header;

alter table tmp add column subregions float8;
update tmp set subregions = a.dist from subregions a where a.g1name = tmp.g1name and a.g2name = tmp.g2name;
\copy (select g1name, g2name, dist, subregions from tmp where subregions is not null) to '/home/grantmckenzie/Documents/COVID19-CommunityMobilityPatterns/internalData/distsubregions.csv' with csv header;

data <-read.csv('../internalData/distsubregions.csv', header=T)

cor.test(data$dist, data$subregions, method='kendall')
mean(data[data$dist == 0,]$subregions)