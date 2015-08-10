## Create results figures for SHG policy module web interface

library(reshape)
library(data.table)
library(scales)

setwd( "C:/Users/jamietam/Dropbox/CISNET/Policy_Module/website" )

# Annual adult smoking prevalence, 2010-2060 ------------------------------

startingyear = 2010
endingyear = 2060

ages18 = NULL
for (i in 18:99) {
  ages18 = rbind(ages18, paste("pop_",i,sep=""))
}

years = NULL
for (i in startingyear:endingyear){
  years = rbind(years, paste("yr",i,sep=""))
}
# Census population projections -------------------------------------------

census <- read.csv("censuspop2010to2060.csv",header=TRUE) # Read in census data
census <- data.table(census) 
# Sum population projections by individual age for each year
censussums <- census[, list(pop_18=sum(pop_18),pop_19=sum(pop_19),                               
                              pop_20=sum(pop_20),pop_21=sum(pop_21),pop_22=sum(pop_22),pop_23=sum(pop_23),pop_24=sum(pop_24),pop_25=sum(pop_25),pop_26=sum(pop_26),pop_27=sum(pop_27),pop_28=sum(pop_28),pop_29=sum(pop_29), 
                              pop_30=sum(pop_30),pop_31=sum(pop_31),pop_32=sum(pop_32),pop_33=sum(pop_33),pop_34=sum(pop_34),pop_35=sum(pop_35),pop_36=sum(pop_36),pop_37=sum(pop_37),pop_38=sum(pop_38),pop_39=sum(pop_39),                    
                              pop_40=sum(pop_40),pop_41=sum(pop_41),pop_42=sum(pop_42),pop_43=sum(pop_43),pop_44=sum(pop_44),pop_45=sum(pop_45),pop_46=sum(pop_46),pop_47=sum(pop_47),pop_48=sum(pop_48),pop_49=sum(pop_49),  
                              pop_50=sum(pop_50),pop_51=sum(pop_51),pop_52=sum(pop_52),pop_53=sum(pop_53),pop_54=sum(pop_54),pop_55=sum(pop_55),pop_56=sum(pop_56),pop_57=sum(pop_57),pop_58=sum(pop_58),pop_59=sum(pop_59),
                              pop_60=sum(pop_60),pop_61=sum(pop_61),pop_62=sum(pop_62),pop_63=sum(pop_63),pop_64=sum(pop_64),pop_65=sum(pop_65),pop_66=sum(pop_66),pop_67=sum(pop_67),pop_68=sum(pop_68),pop_69=sum(pop_69),
                              pop_90=sum(pop_90),pop_91=sum(pop_91),pop_92=sum(pop_92),pop_93=sum(pop_93),pop_94=sum(pop_94),pop_95=sum(pop_95),pop_96=sum(pop_96),pop_97=sum(pop_97),pop_98=sum(pop_98),pop_99=sum(pop_99),
                              pop_80=sum(pop_80),pop_81=sum(pop_81),pop_82=sum(pop_82),pop_83=sum(pop_83),pop_84=sum(pop_84),pop_85=sum(pop_85),pop_86=sum(pop_86),pop_87=sum(pop_87),pop_88=sum(pop_88),pop_89=sum(pop_89),                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                              pop_90=sum(pop_90),pop_91=sum(pop_91),pop_92=sum(pop_92),pop_93=sum(pop_93),pop_94=sum(pop_94),pop_95=sum(pop_95),pop_96=sum(pop_96),pop_97=sum(pop_97),pop_98=sum(pop_98),pop_99=sum(pop_99)                           
                           )
                         ,by=census$year]

population <- as.data.frame(t(censussums)) # Transpose dataframe
population <- population[-1,] # remove first row
colnames(population) <- years
rownames(population) <- ages18

# SHG policy module output ------------------------------------------------
# prevalences <- read.csv("prevalences.csv", header=TRUE) # Read in policy module output data

prevalences <- read.csv("prevalences20coverage.csv", header=TRUE) # Read in policy module output data

adults <- prevalences[prevalences$age>17,] # remove children
adults <- adults[order(adults$year,adults$age,adults$policy_number),]# Sort by year, age, policy

# Split policy module output into baseline and policy scenarios
baseline <- adults[(adults$policy_number==0 & adults$year>=startingyear & adults$year<=endingyear),] 
policy <- adults[(adults$policy_number==1 & adults$year>=startingyear & adults$year<=endingyear),]

# Baseline scenario -------------------------------------------------------
# Reshape the dataframe to the same format as census file
baseline2 <- melt(baseline, id.vars=c("age","year"),measure.vars="smoking_prevalence")
baseline3 <- cast(baseline2, age ~ year)
baselinescenario <- subset(baseline3, select=cbind("2010","2011","2012","2013","2014","2015","2016","2017","2018","2019",
                                            "2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",
                                            "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039",
                                            "2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",
                                            "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059","2060"))
rownames(baselinescenario) <- ages18
colnames(baselinescenario) <- years

# Policy scenario ---------------------------------------------------------
# Reshape the dataframe to the same format as census file
policy2 <- melt(policy, id.vars=c("age","year"),measure.vars="smoking_prevalence")
policy3 <- cast(policy2, age ~ year)
policyscenario <- subset(policy3, select=cbind("2010","2011","2012","2013","2014","2015","2016","2017","2018","2019",
                                                   "2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",
                                                   "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039",
                                                   "2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",
                                                   "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059","2060"))
rownames(policyscenario) <- ages18
colnames(policyscenario) <- years

# Baseline age-specific number of smokers ---------------------------------
# multiply census population sizes by age-specific smoking prevalences
smokpopbaseline <- matrix(ncol=ncol(population),nrow=nrow(population)) 
for (x in 1:ncol(population)){
  for (y in 1:nrow(population)) {
    z <- as.numeric(population[y,x])%o% as.numeric(baselinescenario[y,x])
    smokpopbaseline[y,x] <- z
  }
}
# Policy age-specific number of smokers -----------------------------------
# multiply census population sizes by age-specific smoking prevalences
smokpoppolicy <- matrix(ncol=ncol(population),nrow=nrow(population)) 
for (x in 1:ncol(population)){
  for (y in 1:nrow(population)) {
    z <- as.numeric(population[y,x])%o% as.numeric(policyscenario[y,x])
    smokpoppolicy[y,x] <- z
  }
}
#  ------------------------------------------------------------------------
# Annual smoking prevalence -----------------------------------------------
#  ------------------------------------------------------------------------
smokprevbaseline <- colSums(smokpopbaseline, na.rm=TRUE)/colSums(population,na.rm=TRUE)
smokprevpolicy <- colSums(smokpoppolicy, na.rm=TRUE)/colSums(population,na.rm=TRUE)
prevtablebaseline <- as.data.frame(smokprevbaseline,row.names= c(startingyear:endingyear))
prevtablepolicy<- as.data.frame(smokprevpolicy,row.names= c(startingyear:endingyear))
reduction <-(prevtablebaseline-prevtablepolicy) 
prevtable <- cbind(prevtablebaseline, prevtablepolicy)
prevtable <- cbind(prevtable, reduction)
colnames(prevtable) <- c("Baseline scenario", "Policy scenario", "Prevalence reduction")
summary <- subset(prevtable[c("2020","2030","2040","2050","2060"),])
summarytable = data.frame(matrix(nrow=nrow(summary),ncol=ncol(summary)))
for (x in 1:ncol(summary)){
  for (y in 1:nrow(summary)) {
    z <- sprintf("%.1f %%", 100*summary[y,x])
    summarytable[y,x] <- z
  }
}
colnames(summarytable)=colnames(prevtable)
rownames(summarytable)=c("2020","2030","2040","2050","2060")

## Create HTML for smoking prevalence summary table
# library(xtable)
# print(xtable(summarytable),type="html")

#  ------------------------------------------------------------------------
# Create time-series plot -------------------------------------------------
#  ------------------------------------------------------------------------
pdf('SmokprevAnnual20.pdf')
par(cex.axis=1.3, cex.lab=1.3,cex.main=1.3,cex.sub=1.3,lwd=2)
op <- par(mar = c(5,7,4,2) + 0.1)
plot(c(startingyear:endingyear),smokprevbaseline,type="l",col="blue",lwd=2.0, ylim=c(0.10,0.25), xlab="Year",ylab="", axes=FALSE)
lines(c(startingyear:endingyear),smokprevpolicy,type="l",col="red",lwd=2.0,lty=2)
box()
axis(side=1)
axis(side=2, las=1, at = c(0, 0.05, 0.10, 0.15, 0.20, 0.25))
legend("topright",c("Baseline scenario", "Policy scenario"),lty=c(1,2),lwd=c(2.0,2.0), col=c("blue","red"))
title("U.S. adult smoking prevalence, 2010-2060")
title(ylab="Smoking prevalence", line=4.5)
dev.off()

#  ------------------------------------------------------------------------
# Age-specific smoking prevalence by cohort -------------------------------
#  ------------------------------------------------------------------------
ages=0:99
count=1
cohorts=c(1940,1950,1960,1970,1980,1990)

pdf('SmokprevCohort20.pdf')
par(cex.axis=1.3,cex.lab=1.3,cex.main=1.3,cex.sub=1.3,lwd=2, oma=c(1,1,2,1))
op <- par(mar = c(5,7,6,2) + 0.1)
plot(ages,prevalences$smoking_prevalence[(prevalences$cohort==cohorts[1])&(prevalences$gender==0)&(prevalences$policy_number==0)],type='l',col=count,ylab='',xlab='Age',axes=FALSE)
lines(ages,prevalences$smoking_prevalence[(prevalences$cohort==cohorts[1])&(prevalences$gender==0)&(prevalences$policy_number==1)],col=count,lty=2)
for (cohort in cohorts){
  lines(ages,prevalences$smoking_prevalence[(prevalences$cohort==cohort)&(prevalences$gender==0)&(prevalences$policy_number==0)],col=count)
  lines(ages,prevalences$smoking_prevalence[(prevalences$cohort==cohort)&(prevalences$gender==0)&(prevalences$policy_number==1)],col=count,lty=2)
  count=count+1
}
box()
axis(side=2,las=1)
axis(side=1)
title(ylab="Smoking prevalence", line=4.5)
title(main='Age-specific smoking prevalence by birth-cohort', line=3)
legend('topright',legend=cohorts,lty=1,col=1:length(cohorts))
legend('top',c("Baseline", "Policy"),lty=c(1,2), bty="n", inset=c(0,-0.1),lwd=2.0, col= c("black"), xpd=TRUE, horiz=TRUE)
dev.off()

#  ------------------------------------------------------------------------
# Age-specific smoking prevalence by year ---------------------------------
#  ------------------------------------------------------------------------

count=1
selectyears=c(2000,2010,2020,2030,2040,2050)
specificages <- function(byyear){
  z <- prevalences$age[(prevalences$year==byyear)&(prevalences$policy_number==1)] 
  return(z)
}

pdf('SmokprevYear20.pdf')
par(cex.axis=1.3,cex.lab=1.3,cex.main=1.3,cex.sub=1.3,lwd=2,oma=c(1,1,2,1))
op <- par(mar = c(5,7,6,2) + 0.1)

### FIX THIS PROBLEM  HERE -- TOO MANY LINES GET PRINTED
plot(specificages(selectyears[1]),prevalences$smoking_prevalence[(prevalences$year==selectyears[1])&(prevalences$gender==0)&(prevalences$policy_number==0)],type='l',col=count,ylab='',xlab='Age',axes=FALSE)
lines(specificages(selectyears[1]),prevalences$smoking_prevalence[(prevalences$year==selectyears[1])&(prevalences$gender==0)&(prevalences$policy_number==1)],col=count,lty=2)
for (yr in selectyears){
  lines(specificages(yr),prevalences$smoking_prevalence[(prevalences$year==yr)&(prevalences$gender==0)&(prevalences$policy_number==0)],col=count)
  lines(specificages(yr),prevalences$smoking_prevalence[(prevalences$year==yr)&(prevalences$gender==0)&(prevalences$policy_number==1)],col=count,lty=2)
  count=count+1
}
box()
axis(side=2,las=1)
axis(side=1)
title(ylab="Smoking prevalence", line=4.5)
title(main='Age-specific smoking prevalence by year', line=3)
legend('topright',legend=selectyears,lty=1,col=1:length(selectyears))
legend('top',c("Baseline", "Policy"),lty=c(1,2), bty="n", inset=c(0,-0.1),lwd=2.0, col= c("black"), xpd=TRUE, horiz=TRUE)
dev.off()