mainDir<-"~/p.Diss/C_Commoditisation/forPaper/440131"
setwd(mainDir)


lastdate<-"2017-02-04"
dataset<-c("physimp","physexp","monimp","monexp")

allflows<-data.frame(PARTNER=NA,FLOW=NA,INDICATORS=NA,PRODUCT=NA,REPORTER=NA,FREQ=NA,obsTime=NA,obsValue=NA,OBS_STATUS=NA)
raw<-list(allflows,allflows,allflows,allflows)
specs<-matrix(nrow=5,ncol=5,0)
rownames(specs)<-c(dataset,"summary")
colnames(specs)<-c("obs","zeros","partuni","repuni","time")

for(i in 1:4){
  allflows<-readRDS(paste(dataset[i],lastdate,".rds",sep=""))
  allflows<-allflows[2:dim(allflows)[1],]
  
  ###date into dateformat
  allflows[,7]<-as.Date(paste(allflows[,7],"-01",sep=""),format="%Y-%m-%d")
  
  ###get rid of EU values
  allflows<-allflows[!(allflows[,1]=="EU15_EXTRA"|allflows[,1]=="EU15_INTRA"|allflows[,1]=="EU25_EXTRA"|allflows[,1]=="EU25_INTRA"|
                         allflows[,1]=="EU27_EXTRA"|allflows[,1]=="EU27_INTRA"|allflows[,1]=="EU28_EXTRA"|allflows[,1]=="EU28_INTRA"),]
  
  ###data balance and specifications
  #str(allflows)
  specs[i,1]<-dim(allflows)[1]
  specs[i,5]<-length(unique(allflows[,7])[order(as.Date(unique(allflows[,7]),format="%Y-%m-%d"))])
  specs[i,4]<-length(unique(allflows[,5]))
  specs[i,3]<-length(unique(allflows[,1]))
  specs[i,2]<-dim(allflows[allflows[,8]==0.0|allflows[,8]==0,])[1] 
  raw[[i]]<-allflows
  
}

###complete dataset using bigger (last) one
vals<-expand.grid(obsTime=unique(allflows$obsTime),
                  PARTNER=unique(allflows$PARTNER),
                  REPORTER=unique(allflows$REPORTER))

#specs[2,3]*specs[2,5]*specs[2,4]==dim(vals)[1] #TRUE!
#using last data frame (monetary exports) from the list for creating the allinone data frame 
allflows<-merge(vals,allflows,all=TRUE)
allflows[,8][is.na(allflows[,8])]<-0
allflows<-allflows[,c(1,2,3,8)]
colnames(allflows)<-c("obsTime","PARTNER","REPORTER","monexp")

#binding from raw list monitary imports
allflows<-cbind(allflows,monimp=0)
allflows$monimp<-apply(allflows,1,function(x) if(length(raw[[3]][raw[[3]]$obsTime==x[1]&raw[[3]]$PARTNER==x[2]&raw[[3]]$REPORTER==x[3],8])>0){
  raw[[3]][raw[[3]]$obsTime==x[1]&raw[[3]]$PARTNER==x[2]&raw[[3]]$REPORTER==x[3],8]
}else{0})

#binding from raw list physical exports (&conversion in tonnes)
allflows<-cbind(allflows,physexp=0)
allflows$physexp<-apply(allflows,1,function(x) if(length(raw[[2]][raw[[2]]$obsTime==x[1]&raw[[2]]$PARTNER==x[2]&raw[[2]]$REPORTER==x[3],8])>0){
  raw[[2]][raw[[2]]$obsTime==x[1]&raw[[2]]$PARTNER==x[2]&raw[[2]]$REPORTER==x[3],8]/10
}else{0})

#binding from raw list physical imports (&conversion in tonnes)
allflows<-cbind(allflows,physimp=0)
allflows$physimp<-apply(allflows,1,function(x) if(length(raw[[1]][raw[[1]]$obsTime==x[1]&raw[[1]]$PARTNER==x[2]&raw[[1]]$REPORTER==x[3],8])>0){
  raw[[1]][raw[[1]]$obsTime==x[1]&raw[[1]]$PARTNER==x[2]&raw[[1]]$REPORTER==x[3],8]/10
}else{0})

#clear out trade from REP to REP
allflows$REPORTER<-apply(allflows,1,function(x) if(as.character(x[2])==as.character(x[3])){"OUT"}else{x[3]})
allflows<-allflows[!allflows$REPORTER=="OUT",]

specs[5,1]<-dim(allflows)[1]
specs[5,5]<-length(unique(allflows[,7])[order(as.Date(unique(allflows[,1]),format="%Y-%m-%d"))])
specs[5,4]<-length(unique(allflows[,3]))
specs[5,3]<-length(unique(allflows[,2]))
specs[5,2]<-dim(allflows[allflows[,4]==0&allflows[,5]==0&allflows[,6]==0,])[1] 

saveRDS(allflows,paste("allflows",strtrim(Sys.time(),10),".rds",sep=""))
saveRDS(specs,paste("specs",strtrim(Sys.time(),10),".rds",sep=""))


########################## (load non-Eurostat data)
#library("xlsx", lib.loc="~/R/win-library/3.1")
library("readxl", lib.loc="~/R/win-library/3.1")

preise<-read_excel("biomass_prices_EEG_Jan2017.xlsx",sheet=1,skip=1)
#chips<-read.xlsx("ctryperspectives.xlsx",sheetName="chips",
                 #startRow=8,colIndex=c(3:7))
folge<-c("AT","DE","IT","FR")
pr<-preise[c(2,9,12,17)-1,c(1,6:dim(preise)[2])]
frmto<-seq.Date(as.Date("2000-01-01"),as.Date("2016-12-01"),by="month")

#prm<-matrix(nrow=dim(pr)[2]-1,ncol=5) #change to data frame for not having class problem (as.numeric)
#prm[,1]<-as.Date(frmto)
#prm[,2:5]<-t(pr[,2:dim(pr)[2]])
#colnames(prm)<-c("month",folge)

prm<-data.frame(month=as.Date(frmto),AT=NA,DE=NA,IT=NA,FR=NA)
prm[,2:5]<-t(pr[,2:(dim(pr)[2]-1)])

#exclusive taxes (Italy already excl. taxes in Excel ### assumption that before 2012 as in 2012)
prm[,2]<-
  c(round(as.numeric(prm[prm$month<"2016-01-01",2])*0.9,2),
    round(as.numeric(prm[prm$month>"2015-12-01",2])*0.87,2))+(39/6)
prm[,3]<-round(as.numeric(prm[,3])*0.93)
prm[,5]<-
  c(round(as.numeric(prm[prm$month<"2014-01-01",5])*0.93,2),
    round(as.numeric(prm[prm$month>"2013-12-01",5])*0.9,2))

# safe for graphic later
prmOLD<-prm

# fill out all NA-values in Italy with closest value
itp<-prm[prm$month<"2016-12-01"&prm$month>"2011-12-01",4]

library("zoo", lib.loc="~/R/win-library/3.1")

prm[prm$month<"2016-12-01"&prm$month>"2011-12-01",4]<-
  round(c(242,as.numeric(na.locf(itp))),2) #closest value plus january 2012 at 242,-
prm[,4]<-as.numeric(prm[,4])
#number of business days (all days but weekend)
prm<-cbind(prm,"bd"=0)

frmtoD<-seq.Date(as.Date("2000-01-01"),as.Date("2016-12-01"),by="days")
frmtoBD<-frmtoD[!weekdays(frmtoD)%in%c("Samstag","Sonntag")]
prm$bd<-apply(prm,1,function(x)
  length(frmtoD[grep(format(as.Date(x[1]),"%Y-%m"),frmtoBD)]))

#monthly dummies
prm<-cbind(prm,"md"=0)
prm[,7]<-apply(prm,1,function(x)
  format(as.Date(x[1]),"%m"))

################# back to allflows

#sum of all flows per month
sumflows<-aggregate(allflows[,c(4:7)],list(allflows$obsTime,allflows$REPORTER),sum)
sumflows<-cbind(sumflows,"bd"=0)
sumflows$bd<-apply(sumflows,1,function(x)
  length(frmtoD[grep(format(as.Date(x[1]),"%Y-%m"),frmtoBD)]))
sumflows<-cbind(sumflows,"REP"=0)
sumflows<-sumflows[!sumflows$Group.2=="SE",]
sumflows$REP<-apply(sumflows,1,function(x) as.numeric(prm[prm$month==x[1],1+which(folge==x[2])]))

#import and export shares
allflows<-cbind(allflows,expshare=0)
allflows<-cbind(allflows,impshare=0)

allflows$expshare<-
  apply(allflows,1,function(x) round(as.numeric(x[6])/sumflows[sumflows$Group.1==x[1]&sumflows$Group.2==x[3],5],4))
allflows$expshare<-as.numeric(as.character(allflows$expshare),na.rm=T)
allflows$impshare<-
  apply(allflows,1,function(x) round(as.numeric(x[7])/sumflows[sumflows$Group.1==x[1]&sumflows$Group.2==x[3],6],4))
allflows$impshare<-as.numeric(as.character(allflows$impshare),na.rm=T)

#net-trade
allflows<-cbind(allflows,netexp=0)
allflows$netexp<-round(allflows$physexp-allflows$physimp,1)

#bind month specific data
allflows<-cbind(allflows,bd=0)
allflows$bd<-apply(allflows,1,function(x) as.numeric(prm[prm$month==x[1],]$bd))

allflows<-cbind(allflows,md=0)
allflows$md<-apply(allflows,1,function(x) as.numeric(prm[prm$month==x[1],]$md))

###################################

rel<-matrix(nrow=6,ncol=3)
rel[,1]<-c("DE","IT","AT","IT","FR","IT")
rel[,2]<-c("AT","AT","DE","DE","DE","FR")
rel[,3]<-c("A","B","C","D","E","F")

pnl<-allflows[allflows$PARTNER==rel[1,1]&allflows$REPORTER==rel[1,2],]
for(i in 2:6){
  pnl<-rbind(pnl,allflows[allflows$PARTNER==rel[i,1]&allflows$REPORTER==rel[i,2],])
}

pnl<-cbind(pnl,PARimpshare=0)
pnl$PARimpshare<-apply(pnl,1,function(x) allflows[allflows$obsTime==x[1]&allflows$PARTNER==x[3]&allflows$REPORTER==x[2],]$impshare)

#bind non-eurostat data to pnl
pnl<-cbind(pnl,PAR=0)
pnl<-cbind(pnl,REP=0)
pnl$PAR<-apply(pnl,1,function(x) as.numeric(prm[prm$month==x[1],1+which(folge==x[2])]))
pnl$REP<-apply(pnl,1,function(x) as.numeric(prm[prm$month==x[1],1+which(folge==x[3])]))

#bind dummy for flows
pnl<-cbind(pnl,flw=0)
pnl$flw<-apply(pnl,1,function(x) rel[rel[,1]==x[2]&rel[,2]==x[3],3])

###########################
saveRDS(sumflows,paste("sumflows",strtrim(Sys.time(),10),".rds",sep=""))
saveRDS(allflows,paste("eurostat",strtrim(Sys.time(),10),".rds",sep=""))
saveRDS(pnl,paste("focusset",strtrim(Sys.time(),10),".rds",sep=""))
saveRDS(prm,paste("pricesTS",strtrim(Sys.time(),10),".rds",sep=""))
saveRDS(prmOLD,paste("prmOLD",strtrim(Sys.time(),10),".rds",sep=""))
