#  ------------------------------------------------------------------------
# CREATE RESULTS.CSV FILE FOR SHG POLICY MODULE WEB INTERFACE -------------
#  ------------------------------------------------------------------------
setwd( "C:/Users/jamietam/Dropbox/CISNET/Policy_Module/Website" )
library(reshape)
library(data.table)

# Specify clean air policy parameters
args = c(1,1,1,0,0,0)

Iwp=as.numeric(args[1]) ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir=as.numeric(args[2])  ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib=as.numeric(args[3])  ### indicator of bars policy to be implemented 1-yes, 0-no
pacwp=as.numeric(args[4])  ### percentage already covered by workplace clean air laws
pacr=as.numeric(args[5])   ### percentage already covered by restaurants clean air laws
pacb=as.numeric(args[6])   ### percentage already covered by bars clean air laws

# Select policy years to include in final file
enactpolicy = c(2015,2016,2018,2020)

# Specify age groups to examine
agegroups = c('12 to 17','18 to 24','25 to 44','45 to 64','65+','18 to 99')
agegroupstart = c(12,18,25,45,65,18)
agegroupend = c(17,24,44,64,99,99)

# Read in census data
census <- read.csv("censuspop2010to2060.csv",header=TRUE) 

startingyear = 2010
endingyear = 2060 # goes up to 2100

ages = NULL
for (i in 0:99) {
  ages = rbind(ages, paste("pop_",i,sep=""))
}
years = NULL
for (i in startingyear:endingyear){
  years = rbind(years, paste("yr",i,sep=""))
}

#  ------------------------------------------------------------------------
# Reformat census projections ---------------------------------------------
#  ------------------------------------------------------------------------
census <- data.table(census) 
censussums <- census[, list(pop_0=sum(pop_0),pop_1=sum(pop_1),pop_2=sum(pop_2),pop_3=sum(pop_3),pop_4=sum(pop_4),pop_5=sum(pop_5),pop_6=sum(pop_6),pop_7=sum(pop_7),pop_8=sum(pop_8),pop_9=sum(pop_9),                    
                            pop_10=sum(pop_10),pop_11=sum(pop_11),pop_12=sum(pop_12),pop_13=sum(pop_13),pop_44=sum(pop_14),pop_15=sum(pop_15),pop_16=sum(pop_16),pop_17=sum(pop_17),pop_18=sum(pop_18),pop_19=sum(pop_19), pop_20=sum(pop_20),pop_21=sum(pop_21),pop_22=sum(pop_22),pop_23=sum(pop_23),pop_24=sum(pop_24),pop_25=sum(pop_25),pop_26=sum(pop_26),pop_27=sum(pop_27),pop_28=sum(pop_28),pop_29=sum(pop_29), 
                            pop_30=sum(pop_30),pop_31=sum(pop_31),pop_32=sum(pop_32),pop_33=sum(pop_33),pop_34=sum(pop_34),pop_35=sum(pop_35),pop_36=sum(pop_36),pop_37=sum(pop_37),pop_38=sum(pop_38),pop_39=sum(pop_39),                    
                            pop_40=sum(pop_40),pop_41=sum(pop_41),pop_42=sum(pop_42),pop_43=sum(pop_43),pop_44=sum(pop_44),pop_45=sum(pop_45),pop_46=sum(pop_46),pop_47=sum(pop_47),pop_48=sum(pop_48),pop_49=sum(pop_49),  
                            pop_50=sum(pop_50),pop_51=sum(pop_51),pop_52=sum(pop_52),pop_53=sum(pop_53),pop_54=sum(pop_54),pop_55=sum(pop_55),pop_56=sum(pop_56),pop_57=sum(pop_57),pop_58=sum(pop_58),pop_59=sum(pop_59),
                            pop_60=sum(pop_60),pop_61=sum(pop_61),pop_62=sum(pop_62),pop_63=sum(pop_63),pop_64=sum(pop_64),pop_65=sum(pop_65),pop_66=sum(pop_66),pop_67=sum(pop_67),pop_68=sum(pop_68),pop_69=sum(pop_69),
                            pop_90=sum(pop_90),pop_91=sum(pop_91),pop_92=sum(pop_92),pop_93=sum(pop_93),pop_94=sum(pop_94),pop_95=sum(pop_95),pop_96=sum(pop_96),pop_97=sum(pop_97),pop_98=sum(pop_98),pop_99=sum(pop_99),
                            pop_80=sum(pop_80),pop_81=sum(pop_81),pop_82=sum(pop_82),pop_83=sum(pop_83),pop_84=sum(pop_84),pop_85=sum(pop_85),pop_86=sum(pop_86),pop_87=sum(pop_87),pop_88=sum(pop_88),pop_89=sum(pop_89),                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                            pop_90=sum(pop_90),pop_91=sum(pop_91),pop_92=sum(pop_92),pop_93=sum(pop_93),pop_94=sum(pop_94),pop_95=sum(pop_95),pop_96=sum(pop_96),pop_97=sum(pop_97),pop_98=sum(pop_98),pop_99=sum(pop_99))
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

#  ------------------------------------------------------------------------
# Function to generate results for each year ------------------------------
#  ------------------------------------------------------------------------
createresultsfile <- function(population, popmales, popfemales, prevalencesM, prevalencesF, policy_year,agegroups,agegroupstart, agegroupend){
  # Split policy module output into baseline and policy scenarios -----------
  baselineM <- prevalencesM[(prevalencesM$policy_number==0 & prevalencesM$year>=startingyear & prevalencesM$year<=endingyear),] 
  baselineF <- prevalencesF[(prevalencesF$policy_number==0 & prevalencesF$year>=startingyear & prevalencesF$year<=endingyear),] 
  policyM <- prevalencesM[(prevalencesM$policy_number==1 & prevalencesM$year>=startingyear & prevalencesM$year<=endingyear),]
  policyF <- prevalencesF[(prevalencesF$policy_number==1 & prevalencesF$year>=startingyear & prevalencesF$year<=endingyear),]

  # Create final dataframe with male and female smoking prevalences ---------
  keepvars <- c("year", "age", "cohort", "smoking_prevalence")
  finalprevs <- baselineM[keepvars]
  setnames(finalprevs, "smoking_prevalence", "males_baseline")
  finalprevs <- merge(finalprevs,baselineF[keepvars],by=c("year","age","cohort"))
  setnames(finalprevs, "smoking_prevalence", "females_baseline")
  finalprevs <- merge(finalprevs,policyM[keepvars],by=c("year","age","cohort"))
  setnames(finalprevs, "smoking_prevalence", "males_policy")
  finalprevs <- merge(finalprevs,policyF[keepvars],by=c("year","age","cohort"))
  setnames(finalprevs, "smoking_prevalence", "females_policy")
  
  finalprevs <- finalprevs[order(finalprevs$year,finalprevs$age,finalprevs$cohort),]
  
  # Reshape output dataframes to the same format as census file -------------
  dfs <- list('baselineM', 'baselineF','policyM','policyF')
  
  l <- lapply(dfs, 
              function(df) { 
                df <- get(df)
                df <- melt(df, id.vars=c("age","year"),measure.vars="smoking_prevalence") 
                df <- cast(df, age ~ year)
                df <- subset(df, select=cbind("2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",
                                              "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039","2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",
                                              "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059","2060"))
                rownames(df) <- ages
                colnames(df) <- years                  
                return(df)
              }
  )
  for (d in 1:length(dfs)){
    assign(dfs[[d]], l[[d]])
  }
  
  # Multiply census population by age-specific smoking prevalences ----------
  
  # Baseline scenario, Males - Number of smokers
  smokpopbaseM <- matrix(ncol=ncol(popmales),nrow=nrow(popmales)) 
  for (x in 1:ncol(popmales)){
    for (y in 1:nrow(popmales)) {
      z <- as.numeric(popmales[y,x])%o% as.numeric(baselineM[y,x])
      smokpopbaseM[y,x] <- z
    }
  }
  # Baseline scenario, Females - Number of smokers
  smokpopbaseF <- matrix(ncol=ncol(popfemales),nrow=nrow(popfemales)) 
  for (x in 1:ncol(popfemales)){
    for (y in 1:nrow(popfemales)) {
      z <- as.numeric(popfemales[y,x])%o% as.numeric(baselineF[y,x])
      smokpopbaseF[y,x] <- z
    }
  }
  
  # Policy scenario, Males - Number of smokers
  smokpoppolicyM <- matrix(ncol=ncol(popmales),nrow=nrow(popmales))
  for (x in 1:ncol(popmales)){
    for (y in 1:nrow(popmales)) {
      z <- as.numeric(popmales[y,x])%o% as.numeric(policyM[y,x])
      smokpoppolicyM[y,x] <- z
    }
  }
  # Policy scenario, Females -  Number of smokers
  smokpoppolicyF <- matrix(ncol=ncol(popmales),nrow=nrow(popmales)) 
  for (x in 1:ncol(popmales)){
    for (y in 1:nrow(popmales)) {
      z <- as.numeric(popmales[y,x])%o% as.numeric(policyF[y,x])
      smokpoppolicyF[y,x] <- z
    }
  }
  
  # Generate Total smoking prevalences combining both genders ---------------
  smokerprevs <- function(age,year){ ## Ages 0-99, Years 2010-2060
    baseline_smkprev <- (smokpopbaseM[age+1,year-2009] + smokpopbaseF[age+1,year-2009])/population[age+1,year-2009]
    policy_smkprev <- (smokpoppolicyM[age+1,year-2009] + smokpoppolicyF[age+1,year-2009])/population[age+1,year-2009]
    return(c(baseline_smkprev, policy_smkprev))
  }
  
  for(row in 1:length(finalprevs$age)) { 
    finalprevs$total_baseline[row] <- smokerprevs(finalprevs$age[row], finalprevs$year[row])[1]
    finalprevs$total_policy[row] <- smokerprevs(finalprevs$age[row], finalprevs$year[row])[2]
  }
  
  # Get smoking prevalences by age group ------------------------------------
  finalprevs_agegroups = data.frame()
  for (x in 1:length(agegroups)){
    smokpopbaseMgroup <- smokpopbaseM[(agegroupstart[x]+1):(agegroupend[x]+1),]
    smokpoppolicyMgroup <- smokpoppolicyM[(agegroupstart[x]+1):(agegroupend[x]+1),]
    smokpopbaseFgroup <- smokpopbaseF[(agegroupstart[x]+1):(agegroupend[x]+1),]
    smokpoppolicyFgroup <- smokpoppolicyF[(agegroupstart[x]+1):(agegroupend[x]+1),]
    
    popmalesgroup <- popmales[(agegroupstart[x]+1):(agegroupend[x]+1),]
    popfemalesgroup <- popfemales[(agegroupstart[x]+1):(agegroupend[x]+1),] 
    populationgroup <- population[(agegroupstart[x]+1):(agegroupend[x]+1),]
    
    # Males
    smokprevbaseM <- colSums(smokpopbaseMgroup, na.rm=TRUE)/colSums(popmalesgroup,na.rm=TRUE) 
    smokprevpolicyM <- colSums(smokpoppolicyMgroup, na.rm=TRUE)/colSums(popmalesgroup,na.rm=TRUE)
    prevbaseM <- as.data.frame(smokprevbaseM,row.names= c(startingyear:endingyear))
    prevpolicyM<- as.data.frame(smokprevpolicyM,row.names= c(startingyear:endingyear))
    
    # Females
    smokprevbaseF <- colSums(smokpopbaseFgroup, na.rm=TRUE)/colSums(popfemalesgroup,na.rm=TRUE) 
    smokprevpolicyF <- colSums(smokpoppolicyFgroup, na.rm=TRUE)/colSums(popfemalesgroup,na.rm=TRUE) 
    prevbaseF <- as.data.frame(smokprevbaseF,row.names= c(startingyear:endingyear))
    prevpolicyF<- as.data.frame(smokprevpolicyF,row.names= c(startingyear:endingyear))
    
    # Total population
    smokprevbase <- (colSums(smokpopbaseMgroup, na.rm=TRUE)+colSums(smokpopbaseFgroup,na.rm=TRUE))/colSums(populationgroup,na.rm=TRUE) 
    smokprevpolicy <- (colSums(smokpoppolicyMgroup, na.rm=TRUE)+colSums(smokpoppolicyFgroup, na.rm=TRUE))/colSums(populationgroup,na.rm=TRUE)
    prevbase <- as.data.frame(smokprevbase,row.names= c(startingyear:endingyear))
    prevpolicy<- as.data.frame(smokprevpolicy,row.names= c(startingyear:endingyear))
    
    thisagegroup <- cbind(c(startingyear:endingyear),agegroups[x], "ALL", prevbaseM, prevbaseF, prevpolicyM, prevpolicyF, prevbase, prevpolicy)
    finalprevs_agegroups <- rbind(finalprevs_agegroups,thisagegroup)
  }
  names(finalprevs_agegroups) <- c("year","age","cohort","males_baseline","females_baseline","males_policy","females_policy","total_baseline","total_policy")
  finalprevs <- rbind(finalprevs,finalprevs_agegroups)
  finalprevs$policy_year <- policy_year
  return(finalprevs)
}

#  ------------------------------------------------------------------------
# Write final prevalences dataframe to CSV --------------------------------
#  ------------------------------------------------------------------------
for (i in 1:length(enactpolicy)){

  prevalencesM <- read.csv(paste0('prevalences_males_',enactpolicy[i],'.csv'), header=TRUE) # Read in policy module output data
  prevalencesM <- prevalencesM[order(prevalencesM$year,prevalencesM$age),]# Sort by year, age, policy
  prevalencesF <- read.csv(paste0('prevalences_females_',enactpolicy[i],'.csv'), header=TRUE) 
  prevalencesF <- prevalencesF[order(prevalencesF$year,prevalencesF$age),]# Sort by year, age, policy
  
  finalprevs <- createresultsfile(population,popmales,popfemales,prevalencesM,prevalencesF,enactpolicy[i],agegroups,agegroupstart,agegroupend)
  write.table(finalprevs,paste0('results_w',Iwp,'_r',Ir,'_b',Ib,'_w',pacwp,'_r',pacr, '_b',pacb,'.csv'),col.names=FALSE,row.names=FALSE,sep=',',quote=FALSE,append='TRUE')
  print(paste0("policy for the year ", enactpolicy[i], " appended to file"))
}

# Add header row
finalprevs <- read.csv(paste0('results_w',Iwp,'_r',Ir,'_b',Ib,'_w',pacwp,'_r',pacr, '_b',pacb,'.csv'), header=FALSE)
colnames(finalprevs) = c("year","age","cohort","males_baseline","females_baseline","males_policy","females_policy","total_baseline","total_policy","policy_year")
write.csv(finalprevs, file=paste0('results_w',Iwp,'_r',Ir,'_b',Ib,'_w',pacwp,'_r',pacr, '_b',pacb,'.csv'), row.names=FALSE)
print(paste0('results_w',Iwp,'_r',Ir,'_b',Ib,'_w',pacwp,'_r',pacr, '_b',pacb,'.csv ', 'is ready.'))