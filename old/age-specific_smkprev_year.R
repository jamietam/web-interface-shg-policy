# Age-specific smoking prevalence by year

setwd( "C:/Users/jamietam/Dropbox/CISNET/Policy_Module/website" )

library(reshape)

startingyear = 2010
endingyear = 2060

ages = NULL
for (i in 1:99) {
  ages = rbind(ages, paste("pop_",i,sep=""))
}

years = NULL
for (i in startingyear:endingyear){
  years = rbind(years, paste("yr",i,sep=""))
}


# SHG policy module output ------------------------------------------------
prevalences <- read.csv("prevalences.csv", header=TRUE) # Read in policy module output data
prevalences <- prevalences[prevalences$age>0,] # remove 0-year-olds
prevalences <- prevalences[order(prevalences$year,prevalences$age,prevalences$policy_number),]# Sort by year, age, policy

# Split policy module output into baseline and policy scenarios
baseline <- prevalences[(prevalences$policy_number==0 & prevalences$year>=startingyear & prevalences$year<=endingyear),] 
policy <- prevalences[(prevalences$policy_number==1 & prevalences$year>=startingyear & prevalences$year<=endingyear),]


smkprevbyyear = NULL
for (i in startingyear:endingyear){
  paste
  smkprevbyyear = rbind(smkprevbyyear, paste)
  for (i in startingyear:endingyear){
    years = rbind(years, paste("yr",i,sep=""))
  }
  
  
}

smoking_prevalence

# Baseline scenario -------------------------------------------------------
# Reshape the dataframe to the same format as census file
baseline2 <- melt(baseline, id.vars=c("age","year"),measure.vars="smoking_prevalence")
baseline3 <- cast(baseline2, age ~ year)
baselinescenario <- subset(baseline3, select=cbind("2010","2011","2012","2013","2014","2015","2016","2017","2018","2019",
                                                   "2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",
                                                   "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039",
                                                   "2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",
                                                   "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059","2060"))
rownames(baselinescenario) <- ages
colnames(baselinescenario) <- years
