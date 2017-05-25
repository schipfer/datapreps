##### to download (wood pellet) data from Eurostat and save in an R-data file
setwd("~/p.Diss/C_Commoditisation/forPaper")
require(rsdmx)

##Country codes used by Eurostat
#erostateu28<-c("AT","BE","BG","CY","CZ","DE","DK","EE","ES","FI","FR","GB","GR","HR","HU","IE","IT","LT","LU","LV","MT","NL","PL","PT","RO","SE","SI","SK")
folge<-c("AT","IT","DE","FR","SE")

##Create data format for saving Eurostat data
allflows<-data.frame(PARTNER=NA,FLOW=NA,INDICATORS=NA,PRODUCT=NA,REPORTER=NA,FREQ=NA,obsTime=NA,obsValue=NA,OBS_STATUS=NA)
dataset<-c("physimp","physexp","monimp","monexp")

df<-data.frame(name=dataset,
               flow=c(1,2,1,2),
               unit=c("QUANTITY_IN_100KG","QUANTITY_IN_100KG","VALUE_IN_EUROS","VALUE_IN_EUROS"))

##dataURL has to be modified for each product
##see https://webgate.ec.europa.eu/fpfis/mwikis/sdmx/index.php/Main_Page

dataURL<-rep("",28)
for(d in 1:4){
  for(c in 1:5){
    dataURL[c] <- paste("http://ec.europa.eu/eurostat/SDMX/diss-web/rest/data/DS-016893/M.",folge[c],"..440131.",df$flow[d],".",df$unit[d],"?startperiod=2012",sep="")
    sdmx <- readSDMX(dataURL[c])
    stats <- as.data.frame(sdmx)
    available<-c(stats$OBS_STATUS=="na")
    available[is.na(available)]<-FALSE
    stats<-stats[!available,]
    allflows<-rbind(allflows,stats)
  }
  allflows<-allflows[2:dim(allflows)[1],]
  saveRDS(allflows,file=paste(df$name[d],strtrim(Sys.time(),10),".rds",sep="")) #,format(Sys.time(), "%Y")
  allflows<-data.frame(PARTNER=NA,FLOW=NA,INDICATORS=NA,PRODUCT=NA,REPORTER=NA,FREQ=NA,obsTime=NA,obsValue=NA,OBS_STATUS=NA)
}