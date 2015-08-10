## Create results figures for SHG policy module web interface
setwd( "C:/Users/jamietam/Dropbox/CISNET/Policy_Module/website" )
library(reshape)
library(data.table)

# Read in data ------------------------------------------------------------
census <- read.csv("censuspop2010to2060.csv",header=TRUE) # Read in census data
prevalencesM <- read.csv("prevalences_nocoverage_Men.csv", header=TRUE) # Read in policy module output data
prevalencesM <- subset(prevalencesM, year>=2010)
prevalencesF <- read.csv("prevalences_nocoverage_Women.csv", header=TRUE) 
prevalencesF <- subset(prevalencesF, year>=2010)

# Specify settings for figures ------------------------------
startingyear = 2010
endingyear = 2060
selectyears=c(2015, 2030, 2045, 2060) # Select age-specific smoking prevalence by year and by cohort for Figures
selectcohorts=c(1970,1980,1990,2000,2010)

agegroups = c('12-17','18-24','25-44','45-64','65+','18-99')
agegroupstart = c(12,18,25,45,65,18)
agegroupend = c(17,24,44,64,99,99)
ymax = c(0.08,0.25,0.3,0.25,0.15,0.25)

ages = NULL
for (i in 0:99) {
  ages = rbind(ages, paste("pop_",i,sep=""))
}
years = NULL
for (i in startingyear:endingyear){
  years = rbind(years, paste("yr",i,sep=""))
}

# Reformat census population projections -------------------------------------------
census <- data.table(census) 
censussums <- census[, list(pop_0=sum(pop_0),pop_1=sum(pop_1),pop_2=sum(pop_2),pop_3=sum(pop_3),pop_4=sum(pop_4),pop_5=sum(pop_5),pop_6=sum(pop_6),pop_7=sum(pop_7),pop_8=sum(pop_8),pop_9=sum(pop_9),                    
                            pop_10=sum(pop_10),pop_11=sum(pop_11),pop_12=sum(pop_12),pop_13=sum(pop_13),pop_44=sum(pop_14),pop_15=sum(pop_15),pop_16=sum(pop_16),pop_17=sum(pop_17),pop_18=sum(pop_18),pop_19=sum(pop_19), pop_20=sum(pop_20),pop_21=sum(pop_21),pop_22=sum(pop_22),pop_23=sum(pop_23),pop_24=sum(pop_24),pop_25=sum(pop_25),pop_26=sum(pop_26),pop_27=sum(pop_27),pop_28=sum(pop_28),pop_29=sum(pop_29), 
                              pop_30=sum(pop_30),pop_31=sum(pop_31),pop_32=sum(pop_32),pop_33=sum(pop_33),pop_34=sum(pop_34),pop_35=sum(pop_35),pop_36=sum(pop_36),pop_37=sum(pop_37),pop_38=sum(pop_38),pop_39=sum(pop_39),                    
                              pop_40=sum(pop_40),pop_41=sum(pop_41),pop_42=sum(pop_42),pop_43=sum(pop_43),pop_44=sum(pop_44),pop_45=sum(pop_45),pop_46=sum(pop_46),pop_47=sum(pop_47),pop_48=sum(pop_48),pop_49=sum(pop_49),  
                              pop_50=sum(pop_50),pop_51=sum(pop_51),pop_52=sum(pop_52),pop_53=sum(pop_53),pop_54=sum(pop_54),pop_55=sum(pop_55),pop_56=sum(pop_56),pop_57=sum(pop_57),pop_58=sum(pop_58),pop_59=sum(pop_59),
                              pop_60=sum(pop_60),pop_61=sum(pop_61),pop_62=sum(pop_62),pop_63=sum(pop_63),pop_64=sum(pop_64),pop_65=sum(pop_65),pop_66=sum(pop_66),pop_67=sum(pop_67),pop_68=sum(pop_68),pop_69=sum(pop_69),
                              pop_90=sum(pop_90),pop_91=sum(pop_91),pop_92=sum(pop_92),pop_93=sum(pop_93),pop_94=sum(pop_94),pop_95=sum(pop_95),pop_96=sum(pop_96),pop_97=sum(pop_97),pop_98=sum(pop_98),pop_99=sum(pop_99),
                              pop_80=sum(pop_80),pop_81=sum(pop_81),pop_82=sum(pop_82),pop_83=sum(pop_83),pop_84=sum(pop_84),pop_85=sum(pop_85),pop_86=sum(pop_86),pop_87=sum(pop_87),pop_88=sum(pop_88),pop_89=sum(pop_89),                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                              pop_90=sum(pop_90),pop_91=sum(pop_91),pop_92=sum(pop_92),pop_93=sum(pop_93),pop_94=sum(pop_94),pop_95=sum(pop_95),pop_96=sum(pop_96),pop_97=sum(pop_97),pop_98=sum(pop_98),pop_99=sum(pop_99)                           
                           )
                         ,by=list(year,sex)]
censusmales <- subset(censussums, sex==1)
censusfemales <- subset(censussums, sex==2)
censustotal <- subset(censussums, sex==0)

popfemales <- as.data.frame(t(censusfemales)) # Transpose dataframe
popfemales <- popfemales[-1:-2,] # Remove year and sex rows
colnames(popfemales) <- years
rownames(popfemales) <- ages

popmales <- as.data.frame(t(censusmales)) 
popmales <- popmales[-1:-2,] 
colnames(popmales) <- years
rownames(popmales) <- ages

population <- as.data.frame(t(censustotal))
population <- population[-1:-2,] 
colnames(population) <- years
rownames(population) <- ages

# Split policy module output into baseline and policy scenarios -----------
# men <- prevalencesM[prevalencesM$age>17,] # remove children
prevalencesM <- prevalencesM[order(prevalencesM$year,prevalencesM$age,prevalencesM$policy_number),]# Sort by year, age, policy
baselineM <- prevalencesM[(prevalencesM$policy_number==0 & prevalencesM$year>=startingyear & prevalencesM$year<=endingyear),] 
policyM <- prevalencesM[(prevalencesM$policy_number==1 & prevalencesM$year>=startingyear & prevalencesM$year<=endingyear),]

# women <- prevalencesF[prevalencesF$age>17,]
prevalencesF <- prevalencesF[order(prevalencesF$year,prevalencesF$age,prevalencesF$policy_number),]
baselineF <- prevalencesF[(prevalencesF$policy_number==0 & prevalencesF$year>=startingyear & prevalencesF$year<=endingyear),] 
policyF <- prevalencesF[(prevalencesF$policy_number==1 & prevalencesF$year>=startingyear & prevalencesF$year<=endingyear),]


# Reshape the dataframe to the same format as census file -----------------
baselineM <- melt(baselineM, id.vars=c("age","year"),measure.vars="smoking_prevalence") # Baseline scenario, males
baselineM <- cast(baselineM, age ~ year)
baselineM <- subset(baselineM, select=cbind("2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",
                                            "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039","2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",
                                            "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059","2060"))
rownames(baselineM) <- ages
colnames(baselineM) <- years

baselineF <- melt(baselineF, id.vars=c("age","year"),measure.vars="smoking_prevalence") # Baseline scenario, females
baselineF <- cast(baselineF, age ~ year)
baselineF <- subset(baselineF, select=cbind("2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",
                                                    "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039","2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",
                                                    "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059","2060"))
rownames(baselineF) <- ages
colnames(baselineF) <- years

policyM <- melt(policyM, id.vars=c("age","year"),measure.vars="smoking_prevalence") # Policy scenario, males
policyM <- cast(policyM, age ~ year)
policyM <- subset(policyM, select=cbind("2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",
                                        "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039","2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",
                                        "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059","2060"))
rownames(policyM) <- ages
colnames(policyM) <- years

policyF <- melt(policyF, id.vars=c("age","year"),measure.vars="smoking_prevalence") # Policy scenario, females
policyF <- cast(policyF, age ~ year)
policyF <- subset(policyF, select=cbind("2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",
                                        "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039","2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",
                                        "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059","2060"))
rownames(policyF) <- ages
colnames(policyF) <- years

# Multiply census population by age-specific smoking prevalences ----------
smokpopbaseM <- matrix(ncol=ncol(popmales),nrow=nrow(popmales)) # Baseline scenario, Males
for (x in 1:ncol(popmales)){
  for (y in 1:nrow(popmales)) {
    z <- as.numeric(popmales[y,x])%o% as.numeric(baselineM[y,x])
    smokpopbaseM[y,x] <- z
  }
}
smokpoppolicyM <- matrix(ncol=ncol(popmales),nrow=nrow(popmales)) # Policy scenario, Males
for (x in 1:ncol(popmales)){
  for (y in 1:nrow(popmales)) {
    z <- as.numeric(popmales[y,x])%o% as.numeric(policyM[y,x])
    smokpoppolicyM[y,x] <- z
  }
}
smokpopbaseF <- matrix(ncol=ncol(popfemales),nrow=nrow(popfemales)) # Baseline scenario - Females
for (x in 1:ncol(popfemales)){
  for (y in 1:nrow(popfemales)) {
    z <- as.numeric(popfemales[y,x])%o% as.numeric(baselineF[y,x])
    smokpopbaseF[y,x] <- z
  }
}
smokpoppolicyF <- matrix(ncol=ncol(popmales),nrow=nrow(popmales)) # Policy scenario - Females
for (x in 1:ncol(popmales)){
  for (y in 1:nrow(popmales)) {
    z <- as.numeric(popmales[y,x])%o% as.numeric(policyF[y,x])
    smokpoppolicyF[y,x] <- z
  }
}

#  ------------------------------------------------------------------------
# Annual smoking prevalence -----------------------------------------------
#  ------------------------------------------------------------------------
for (x in 1:length(agegroups)){
  smokpopbaseMgroup <- smokpopbaseM[(agegroupstart[x]+1):(agegroupend[x]+1),]
  smokpopbaseFgroup <- smokpopbaseF[(agegroupstart[x]+1):(agegroupend[x]+1),]
  
  smokpoppolicyMgroup <- smokpoppolicyM[(agegroupstart[x]+1):(agegroupend[x]+1),]
  smokpoppolicyFgroup <- smokpoppolicyF[(agegroupstart[x]+1):(agegroupend[x]+1),]
  
  populationgroup <- population[(agegroupstart[x]+1):(agegroupend[x]+1),]
  popmalesgroup <- popmales[(agegroupstart[x]+1):(agegroupend[x]+1),]
  popfemalesgroup <- popfemales[(agegroupstart[x]+1):(agegroupend[x]+1),]  
  
  smokprevbase <- (colSums(smokpopbaseMgroup, na.rm=TRUE)+colSums(smokpopbaseFgroup,na.rm=TRUE))/colSums(populationgroup,na.rm=TRUE) # Total population
  smokprevpolicy <- (colSums(smokpoppolicyMgroup, na.rm=TRUE)+colSums(smokpoppolicyFgroup, na.rm=TRUE))/colSums(populationgroup,na.rm=TRUE)

  smokprevbaseM <- colSums(smokpopbaseMgroup, na.rm=TRUE)/colSums(popmalesgroup,na.rm=TRUE) 
  smokprevpolicyM <- colSums(smokpoppolicyMgroup, na.rm=TRUE)/colSums(popmalesgroup,na.rm=TRUE)

  smokprevbaseF <- colSums(smokpopbaseFgroup, na.rm=TRUE)/colSums(popfemalesgroup,na.rm=TRUE) # Women only
  smokprevpolicyF <- colSums(smokpoppolicyFgroup, na.rm=TRUE)/colSums(popfemalesgroup,na.rm=TRUE)  

  pdf(paste('SmokprevAnnual_nocoverage_',agegroups[x],'.pdf',sep="")) ### CHECK FILE NAME
  par(cex.axis=1.3, cex.lab=1.3,cex.main=1.3,cex.sub=1.3,lwd=2)
  op <- par(mar = c(5,7,6,2) + 0.1)
  plot(c(startingyear:endingyear),smokprevbase,type="l",col="black",lwd=2.0, ylim=c(0.0,ymax[x]), xlab="Year",ylab="", axes=FALSE)
#   plot(c(startingyear:endingyear),smokprevbase,type="l",col="black",lwd=2.0, xlab="Year",ylab="", axes=FALSE)
  lines(c(startingyear:endingyear),smokprevpolicy,type="l",col="black",lwd=2.0,lty=2)
  lines(c(startingyear:endingyear),smokprevbaseM,type="l",col="blue",lwd=2.0,lty=1)
  lines(c(startingyear:endingyear),smokprevpolicyM,type="l",col="blue",lwd=2.0,lty=2)
  lines(c(startingyear:endingyear),smokprevbaseF,type="l",col="red",lwd=2.0,lty=1)
  lines(c(startingyear:endingyear),smokprevpolicyF,type="l",col="red",lwd=2.0,lty=2)
  box()
  axis(side=1)
#   axis(side=2, las=1, at = c(0, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30))
  axis(side=2, las=1)
  
  legend("topright",c("Males","Females","Both sexes"),lty=c(1,1,1),lwd=c(2.0,2.0), col=c("blue","red","black"))
  legend('top',c("Baseline", "Policy"),lty=c(1,2), bty="n", inset=c(0,-0.1),lwd=2.0, col= c("black"), xpd=TRUE, horiz=TRUE)
  title(paste('U.S. smoking prevalence ages ',agegroups[x],', 2010-2060'))
  title(ylab="Smoking prevalence", line=4.5)
  dev.off()

}

#  ------------------------------------------------------------------------
# Create summary tables ---------------------------------------------------
#  ------------------------------------------------------------------------

## Adults only if using the last age group from for loop

# smokprevbase <- (colSums(smokpopbaseMgroup, na.rm=TRUE)+colSums(smokpopbaseFgroup,na.rm=TRUE))/colSums(populationgroup,na.rm=TRUE) # Total population
# smokprevpolicy <- (colSums(smokpoppolicyMgroup, na.rm=TRUE)+colSums(smokpoppolicyFgroup, na.rm=TRUE))/colSums(populationgroup,na.rm=TRUE)
# 
# smokprevbaseM <- colSums(smokpopbaseMgroup, na.rm=TRUE)/colSums(popmalesgroup,na.rm=TRUE) 
# smokprevpolicyM <- colSums(smokpoppolicyMgroup, na.rm=TRUE)/colSums(popmalesgroup,na.rm=TRUE)
# 
# smokprevbaseF <- colSums(smokpopbaseFgroup, na.rm=TRUE)/colSums(popfemalesgroup,na.rm=TRUE) # Women only
# smokprevpolicyF <- colSums(smokpoppolicyFgroup, na.rm=TRUE)/colSums(popfemalesgroup,na.rm=TRUE)  

prevbase <- as.data.frame(smokprevbase,row.names= c(startingyear:endingyear))
prevpolicy<- as.data.frame(smokprevpolicy,row.names= c(startingyear:endingyear))
reduction <-(prevbase-prevpolicy) 

prevbaseM <- as.data.frame(smokprevbaseM,row.names= c(startingyear:endingyear))
prevpolicyM<- as.data.frame(smokprevpolicyM,row.names= c(startingyear:endingyear))
reductionM <-(prevbaseM-prevpolicyM) 

prevbaseF <- as.data.frame(smokprevbaseF,row.names= c(startingyear:endingyear))
prevpolicyF<- as.data.frame(smokprevpolicyF,row.names= c(startingyear:endingyear))
reductionF <-(prevbaseF-prevpolicyF) 

prevtable <- cbind(prevbase, prevbaseM, prevbaseF, prevpolicy, prevpolicyM, prevpolicyF,reduction,reductionM,reductionF)
colnames(prevtable) <- c("Baseline scenario", "Baseline - Males", "Baseline - Females", "Policy scenario", "Policy - Men", "Policy - Women", "Prevalence reduction", "Reduction - Men", "Reduction - Women")

summary <- subset(prevtable[c("2015","2030","2045","2060"),])
summarytable = data.frame(matrix(nrow=nrow(summary),ncol=ncol(summary)))
for (x in 1:ncol(summary)){
  for (y in 1:nrow(summary)) {
    z <- sprintf("%.1f %%", 100*summary[y,x])
    summarytable[y,x] <- z
  }
}
colnames(summarytable)=colnames(prevtable)
rownames(summarytable)=c("2015","2030","2045","2060")

# write.csv(summarytable, file="summarysmokprev_nocov.csv")

## Create HTML for smoking prevalence summary table
# library(xtable)
# print(xtable(summarytable),type="html")

#  ------------------------------------------------------------------------
# Age-specific smoking prevalence by cohort -------------------------------
#  ------------------------------------------------------------------------

count=1
cohortages <- function(birthcohort){
  z <- prevalencesM$age[(prevalencesM$cohort==birthcohort)&(prevalencesM$policy_number==1)] 
  return(z)
}

pdf('SmokprevCohort_nocov_Males.pdf') ### CHECK FILE NAME
# jpeg('SmokprevCohort_nocov_Males.jpg')
par(cex.axis=1.3,cex.lab=1.3,cex.main=1.3,cex.sub=1.3,lwd=2, oma=c(1,1,2,1))
op <- par(mar = c(5,7,6,2) + 0.1)
plot(NULL, xlim=c(0,100),ylim=c(0,0.4),ylab='',xlab='Age',axes=FALSE)
for (birthcohort in selectcohorts){
  lines(cohortages(birthcohort),prevalencesM$smoking_prevalence[(prevalencesM$cohort==birthcohort)&(prevalencesM$gender==0)&(prevalencesM$policy_number==0)],col=count, lty=1)
  lines(cohortages(birthcohort),prevalencesM$smoking_prevalence[(prevalencesM$cohort==birthcohort)&(prevalencesM$gender==0)&(prevalencesM$policy_number==1)],col=count,lty=2)
  count=count+1
}
box()
axis(side=2,las=1)
axis(side=1)
title(ylab="Smoking prevalence", line=4.5)
title(main='Smoking prevalence by birth-cohort - Males', line=3)
legend('topright',legend=selectcohorts,lty=1,col=1:length(selectcohorts))
legend('top',c("Baseline", "Policy"),lty=c(1,2), bty="n", inset=c(0,-0.1),lwd=2.0, col= c("black"), xpd=TRUE, horiz=TRUE)
dev.off()

count=1
cohortages <- function(birthcohort){
  z <- prevalencesF$age[(prevalencesF$cohort==birthcohort)&(prevalencesF$policy_number==1)] 
  return(z)
}
pdf('SmokprevCohort_nocov_Females.pdf') ### CHECK FILE NAME
# jpeg('SmokprevCohort_nocov_Females.jpg') ### CHECK FILE NAME
par(cex.axis=1.3,cex.lab=1.3,cex.main=1.3,cex.sub=1.3,lwd=2, oma=c(1,1,2,1))
op <- par(mar = c(5,7,6,2) + 0.1)
plot(NULL, xlim=c(0,100),ylim=c(0,0.4),ylab='',xlab='Age',axes=FALSE)
for (birthcohort in selectcohorts){
  lines(cohortages(birthcohort),prevalencesF$smoking_prevalence[(prevalencesF$cohort==birthcohort)&(prevalencesF$gender==1)&(prevalencesF$policy_number==0)],col=count, lty=1)
  lines(cohortages(birthcohort),prevalencesF$smoking_prevalence[(prevalencesF$cohort==birthcohort)&(prevalencesF$gender==1)&(prevalencesF$policy_number==1)],col=count,lty=2)
  count=count+1
}
box()
axis(side=2,las=1)
axis(side=1)
title(ylab="Smoking prevalence", line=4.5)
title(main='Smoking prevalence by birth-cohort - Females', line=3)
legend('topright',legend=selectcohorts,lty=1,col=1:length(selectcohorts))
legend('top',c("Baseline", "Policy"),lty=c(1,2), bty="n", inset=c(0,-0.1),lwd=2.0, col= c("black"), xpd=TRUE, horiz=TRUE)
dev.off()

#  ------------------------------------------------------------------------
# Age-specific smoking prevalence by year ---------------------------------
#  ------------------------------------------------------------------------
count=1
specificages <- function(byyear){
  z <- prevalencesM$age[(prevalencesM$year==byyear)&(prevalencesM$policy_number==1)] 
  return(z)
}

pdf('SmokprevYear_nocov_Males.pdf')
# jpeg('SmokprevYear_nocov_Males.jpg')
par(cex.axis=1.3,cex.lab=1.3,cex.main=1.3,cex.sub=1.3,lwd=2,oma=c(1,1,2,1))
op <- par(mar = c(5,7,6,2) + 0.1)
prevalencesM <- prevalencesM[order(prevalencesM$age),]
plot(NULL, xlim=c(0,100),ylim=c(0,0.35),ylab='',xlab='Age',axes=FALSE)
for (yr in selectyears){
  lines(specificages(yr),prevalencesM$smoking_prevalence[(prevalencesM$year==yr)&(prevalencesM$gender==0)&(prevalencesM$policy_number==0)],col=count)
  lines(specificages(yr),prevalencesM$smoking_prevalence[(prevalencesM$year==yr)&(prevalencesM$gender==0)&(prevalencesM$policy_number==1)],col=count,lty=2)
  count=count+1
}
box()
axis(side=2,las=1)
axis(side=1)
title(ylab="Smoking prevalence", line=4.5)
title(main='Smoking prevalence by year - Males', line=3)
legend('topright',legend=selectyears,lty=1,col=1:length(selectyears))
legend('top',c("Baseline", "Policy"),lty=c(1,2), bty="n", inset=c(0,-0.1),lwd=2.0, col= c("black"), xpd=TRUE, horiz=TRUE)
dev.off()

count=1
specificages <- function(byyear){
  z <- prevalencesF$age[(prevalencesF$year==byyear)&(prevalencesF$policy_number==1)] 
  return(z)
}

pdf('SmokprevYear_nocov_Females.pdf')
# jpeg('SmokprevYear_nocov_females.jpg')
par(cex.axis=1.3,cex.lab=1.3,cex.main=1.3,cex.sub=1.3,lwd=2,oma=c(1,1,2,1))
op <- par(mar = c(5,7,6,2) + 0.1)
prevalencesF <- prevalencesF[order(prevalencesF$age),]
plot(NULL, xlim=c(0,100),ylim=c(0,0.35),ylab='',xlab='Age',axes=FALSE)
for (yr in selectyears){
  lines(specificages(yr),prevalencesF$smoking_prevalence[(prevalencesF$year==yr)&(prevalencesF$gender==1)&(prevalencesF$policy_number==0)],col=count)
  lines(specificages(yr),prevalencesF$smoking_prevalence[(prevalencesF$year==yr)&(prevalencesF$gender==1)&(prevalencesF$policy_number==1)],col=count,lty=2)
  count=count+1
}
box()
axis(side=2,las=1)
axis(side=1)
title(ylab="Smoking prevalence", line=4.5)
title(main='Smoking prevalence by year - Females', line=3)
legend('topright',legend=selectyears,lty=1,col=1:length(selectyears))
legend('top',c("Baseline", "Policy"),lty=c(1,2), bty="n", inset=c(0,-0.1),lwd=2.0, col= c("black"), xpd=TRUE, horiz=TRUE)
dev.off()
