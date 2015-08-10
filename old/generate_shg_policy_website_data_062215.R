#  ------------------------------------------------------------------------
# CREATE RESULTS.CSV FILE FOR SHG POLICY MODULE WEB INTERFACE -------------
#  ------------------------------------------------------------------------
setwd( "C:/Users/jamietam/Dropbox/CISNET/Policy_Module/Website" )
library(reshape)
library(data.table)

# Read in policy module output data
prevalencesM <- read.csv(paste0('prevalences_males_2015.csv'), header=TRUE) 
prevalencesF <- read.csv(paste0('prevalences_females_2015.csv'), header=TRUE)

# Read in Census data
popmales <- read.csv("censusdata/censuspop_males.csv",header=TRUE)
popmales <- popmales[,-1] # Remove 1st column "ages"
popfemales <- read.csv("censusdata/censuspop_females.csv",header=TRUE)
popfemales <- popfemales[,-1] # Remove 1st column "ages"
population <- read.csv("censusdata/censuspopulation_total.csv",header=TRUE)
population <- population[,-1] # Remove 1st column "ages"

# Read in death rates
acm_males_current <- read.csv("acmratesbysmokingstatus/acm_males_current.csv",header=TRUE)
acm_males_former <- read.csv("acmratesbysmokingstatus/acm_males_former.csv",header=TRUE)
acm_males_never <- read.csv("acmratesbysmokingstatus/acm_males_never.csv",header=TRUE)

acm_females_current <- read.csv("acmratesbysmokingstatus/acm_females_current.csv",header=TRUE)
acm_females_former <- read.csv("acmratesbysmokingstatus/acm_females_former.csv",header=TRUE)
acm_females_never <- read.csv("acmratesbysmokingstatus/acm_females_never.csv",header=TRUE)

tobaccodeaths_males_current <- acm_males_current[,-1] - acm_males_never[,-1]
tobaccodeaths_males_former <- acm_males_former[,-1] - acm_males_never[,-1]

tobaccodeaths_females_current <- acm_females_current[,-1] - acm_females_never[,-1]
tobaccodeaths_females_former <- acm_females_former[,-1] - acm_females_never[,-1]

# Specify clean air policy parameters
args = c(1,1,1,0,0,0)

Iwp=as.numeric(args[1]) ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir=as.numeric(args[2])  ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib=as.numeric(args[3])  ### indicator of bars policy to be implemented 1-yes, 0-no
pacwp=as.numeric(args[4])  ### percentage already covered by workplace clean air laws
pacr=as.numeric(args[5])   ### percentage already covered by restaurants clean air laws
pacb=as.numeric(args[6])   ### percentage already covered by bars clean air laws

# Select policy years to include in final file
# enactpolicy = c(2015,2016,2018,2020)
enactpolicy = c(2015)


# Specify age groups to examine
agegroups = c('12 to 17','18 to 24','25 to 44','45 to 64','65+','18 to 99')
agegroupstart = c(12,18,25,45,65,18)
agegroupend = c(17,24,44,64,99,99)

startingyear = 2010
endingyear = 2060 
ages = NULL
for (i in 0:99) {
  ages = rbind(ages, paste("pop_",i,sep=""))
}
years = NULL
for (i in startingyear:endingyear){
  years = rbind(years, paste("yr",i,sep=""))
}

#  ------------------------------------------------------------------------
# Function to generate results for each year ------------------------------
#  ------------------------------------------------------------------------
createresultsfile <- function(population, popmales, popfemales, prevalencesM, prevalencesF, policy_year,agegroups,agegroupstart, agegroupend){
  # Split policy module output into baseline and policy scenarios -----------
  baselineM <- prevalencesM[(prevalencesM$policy_number==0 & prevalencesM$year>=startingyear & prevalencesM$year<=endingyear),] 
  baselineF <- prevalencesF[(prevalencesF$policy_number==0 & prevalencesF$year>=startingyear & prevalencesF$year<=endingyear),] 
  policyM <- prevalencesM[(prevalencesM$policy_number==1 & prevalencesM$year>=startingyear & prevalencesM$year<=endingyear),]
  policyF <- prevalencesF[(prevalencesF$policy_number==1 & prevalencesF$year>=startingyear & prevalencesF$year<=endingyear),]
  
  baselineM_former <- baselineM
  baselineF_former <- baselineF
  policyM_former <- policyM
  policyF_former <- policyF
  
  # Create final dataframe with male and female smoking prevalences ---------
  keepvars <- c("year", "age", "cohort", "smoking_prevalence","former_prevalence")
  
  finalprevs <- baselineM[keepvars]
  setnames(finalprevs, "smoking_prevalence", "males_baseline")
  setnames(finalprevs, "former_prevalence", "males_former_baseline")
  finalprevs <- merge(finalprevs,baselineF[keepvars],by=c("year","age","cohort"))
  setnames(finalprevs, "smoking_prevalence", "females_baseline")
  setnames(finalprevs, "former_prevalence", "females_former_baseline")
  finalprevs <- merge(finalprevs,policyM[keepvars],by=c("year","age","cohort"))
  setnames(finalprevs, "smoking_prevalence", "males_policy")
  setnames(finalprevs, "former_prevalence", "males_former_policy")
  finalprevs <- merge(finalprevs,policyF[keepvars],by=c("year","age","cohort"))
  setnames(finalprevs, "smoking_prevalence", "females_policy")
  setnames(finalprevs, "former_prevalence", "females_former_policy")
  
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

  # Reshape former prevalence dataframe -------------------------------------
  dfs_former <- list('baselineM_former','baselineF_former','policyM_former','policyF_former')

  l_former <- lapply(dfs_former, 
              function(df) { 
                df <- get(df)
                df <- melt(df, id.vars=c("age","year"),measure.vars="former_prevalence") 
                df <- cast(df, age ~ year)
                df <- subset(df, select=cbind("2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",
                                              "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039","2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",
                                              "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059","2060"))
                rownames(df) <- ages
                colnames(df) <- years                  
                return(df)
              }
  )
  for (f in 1:length(dfs_former)){
    assign(dfs_former[[f]], l_former[[f]])
  }
  
  # Multiply census population by age-specific prevalences ----------
  
  # Baseline scenario, Males - Number of smokers
  smokpopbaseM <- matrix(ncol=ncol(popmales),nrow=nrow(popmales)) 
  for (x in 1:ncol(popmales)){
    for (y in 1:nrow(popmales)) {
      z <- as.numeric(popmales[y,x])%o% as.numeric(baselineM[y,x])
      smokpopbaseM[y,x] <- z
    }
  }
  # Baseline scenario, Males - Number of former smokers
  formerpopbaseM <- matrix(ncol=ncol(popmales),nrow=nrow(popmales)) 
  for (x in 1:ncol(popmales)){
    for (y in 1:nrow(popmales)) {
      z <- as.numeric(popmales[y,x])%o% as.numeric(baselineM_former[y,x])
      formerpopbaseM[y,x] <- z
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
  # Baseline scenario, Females - Number of former smokers
  formerpopbaseF <- matrix(ncol=ncol(popfemales),nrow=nrow(popfemales)) 
  for (x in 1:ncol(popfemales)){
    for (y in 1:nrow(popfemales)) {
      z <- as.numeric(popfemales[y,x])%o% as.numeric(baselineF_former[y,x])
      formerpopbaseF[y,x] <- z
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
  
  # Policy scenario, Males - Number of former smokers
  formerpoppolicyM <- matrix(ncol=ncol(popmales),nrow=nrow(popmales))
  for (x in 1:ncol(popmales)){
    for (y in 1:nrow(popmales)) {
      z <- as.numeric(popmales[y,x])%o% as.numeric(policyM_former[y,x])
      formerpoppolicyM[y,x] <- z
    }
  }
  # Policy scenario, Females -  Number of smokers
  smokpoppolicyF <- matrix(ncol=ncol(popfemales),nrow=nrow(popfemales)) 
  for (x in 1:ncol(popfemales)){
    for (y in 1:nrow(popfemales)) {
      z <- as.numeric(popfemales[y,x])%o% as.numeric(policyF[y,x])
      smokpoppolicyF[y,x] <- z
    }
  }
  # Policy scenario, Females -  Number of former smokers
  formerpoppolicyF <- matrix(ncol=ncol(popfemales),nrow=nrow(popfemales)) 
  for (x in 1:ncol(popfemales)){
    for (y in 1:nrow(popfemales)) {
      z <- as.numeric(popfemales[y,x])%o% as.numeric(policyF_former[y,x])
      formerpoppolicyF[y,x] <- z
    }
  }  
  # Generate Total smoking prevalences combining both genders ---------------
  smokerprevs <- function(age,year){ ## Ages 0-99, Years 2010-2060
    baseline_smkprev <- (smokpopbaseM[age+1,year-2009] + smokpopbaseF[age+1,year-2009])/population[age+1,year-2009]
    policy_smkprev <- (smokpoppolicyM[age+1,year-2009] + smokpoppolicyF[age+1,year-2009])/population[age+1,year-2009]       
    return(c(baseline_smkprev, policy_smkprev))
  }
  
  getdeathcounts <- function(age,year){
    # Generate tobacco-related death counts = excess smoker deaths + excess former deaths
    tobaccodeathsM_base <- tobaccodeaths_males_current[age+1,year-2009]*smokpopbaseM[age+1,year-2009] + tobaccodeaths_males_former[age+1,year-2009]*formerpopbaseM[age+1,year-2009]
    tobaccodeathsM_pol <- tobaccodeaths_males_current[age+1,year-2009]*smokpoppolicyM[age+1,year-2009] + tobaccodeaths_males_former[age+1,year-2009]*formerpoppolicyM[age+1,year-2009]
    tobaccodeathsF_base <- tobaccodeaths_females_current[age+1,year-2009]*smokpopbaseF[age+1,year-2009] + tobaccodeaths_females_former[age+1,year-2009]*formerpopbaseF[age+1,year-2009]
    tobaccodeathsF_pol <- tobaccodeaths_females_current[age+1,year-2009]*smokpoppolicyF[age+1,year-2009] + tobaccodeaths_females_former[age+1,year-2009]*formerpoppolicyF[age+1,year-2009]
    return(c(tobaccodeathsM_base,tobaccodeathsM_pol,tobaccodeathsF_base,tobaccodeathsF_pol))
  }
  for(row in 1:length(finalprevs$age)) { 
    finalprevs$totalprev_baseline[row] <- smokerprevs(finalprevs$age[row], finalprevs$year[row])[1]
    finalprevs$totalprev_policy[row] <- smokerprevs(finalprevs$age[row], finalprevs$year[row])[2]
    
    finalprevs$tobaccodeathsM_baseline[row] <- getdeathcounts(finalprevs$age[row], finalprevs$year[row])[1]
    finalprevs$tobaccodeathsM_policy[row] <- getdeathcounts(finalprevs$age[row], finalprevs$year[row])[2]
    finalprevs$deathsM_avoided[row] <- finalprevs$tobaccodeathsM_baseline[row]-finalprevs$tobaccodeathsM_policy[row]
    
    finalprevs$tobaccodeathsF_baseline[row] <- getdeathcounts(finalprevs$age[row], finalprevs$year[row])[3]
    finalprevs$tobaccodeathsF_policy[row] <- getdeathcounts(finalprevs$age[row], finalprevs$year[row])[4]
    finalprevs$deathsF_avoided[row] <- finalprevs$tobaccodeathsF_baseline[row]-finalprevs$tobaccodeathsF_policy[row]
    
    finalprevs$tobaccodeaths_baseline[row] <- finalprevs$tobaccodeathsM_baseline[row]+finalprevs$tobaccodeathsF_baseline[row]
    finalprevs$tobaccodeaths_policy[row] <- finalprevs$tobaccodeathsM_policy[row]+finalprevs$tobaccodeathsF_policy[row]
    finalprevs$deaths_avoided[row] <- finalprevs$tobaccodeaths_baseline[row]-finalprevs$tobaccodeaths_policy[row]
  }
#   write.csv(finalprevs,file="finalprevs_checkfile.csv")

  gettobaccodeaths_agegroup <- function(finalprevs,specifyyear,agestart,ageend){
    thisgrouponly <- finalprevs[(finalprevs$age>=agestart & finalprevs$age<=ageend &finalprevs$year==specifyyear),] 
    deaths <- colSums(thisgrouponly[c("tobaccodeathsM_baseline", "tobaccodeathsM_policy", "deathsM_avoided","tobaccodeathsF_baseline","tobaccodeathsF_policy","deathsF_avoided","tobaccodeaths_baseline","tobaccodeaths_policy","deaths_avoided")], na.rm = TRUE)
    return(deaths)
  }
  
  # Get smoking prevalences by age group ------------------------------------
  finalprevs_agegroups = data.frame()
  for (x in 1:length(agegroups)){
    smokpopbaseMgroup <- smokpopbaseM[(agegroupstart[x]+1):(agegroupend[x]+1),]
    smokpoppolicyMgroup <- smokpoppolicyM[(agegroupstart[x]+1):(agegroupend[x]+1),]
    smokpopbaseFgroup <- smokpopbaseF[(agegroupstart[x]+1):(agegroupend[x]+1),]
    smokpoppolicyFgroup <- smokpoppolicyF[(agegroupstart[x]+1):(agegroupend[x]+1),]
  
    formerpopbaseMgroup <- formerpopbaseM[(agegroupstart[x]+1):(agegroupend[x]+1),]
    formerpoppolicyMgroup <- formerpoppolicyM[(agegroupstart[x]+1):(agegroupend[x]+1),]
    formerpopbaseFgroup <- formerpopbaseF[(agegroupstart[x]+1):(agegroupend[x]+1),]
    formerpoppolicyFgroup <- formerpoppolicyF[(agegroupstart[x]+1):(agegroupend[x]+1),]
    
    popmalesgroup <- popmales[(agegroupstart[x]+1):(agegroupend[x]+1),]
    popfemalesgroup <- popfemales[(agegroupstart[x]+1):(agegroupend[x]+1),] 
    populationgroup <- population[(agegroupstart[x]+1):(agegroupend[x]+1),]
    
    # Males
    smokprevbaseM <- colSums(smokpopbaseMgroup, na.rm=TRUE)/colSums(popmalesgroup,na.rm=TRUE) 
    smokprevpolicyM <- colSums(smokpoppolicyMgroup, na.rm=TRUE)/colSums(popmalesgroup,na.rm=TRUE)
    prevbaseM <- as.data.frame(smokprevbaseM,row.names= c(startingyear:endingyear))
    prevpolicyM<- as.data.frame(smokprevpolicyM,row.names= c(startingyear:endingyear))
    
    formerprevbaseM <- #################FIX THIS HERE
    formerprevbaseM <- colSums(formerpopbaseMgroup, na.rm=TRUE)/colSums(popmalesgroup,na.rm=TRUE) 
    formerprevpolicyM <- colSums(formerpoppolicyMgroup, na.rm=TRUE)/colSums(popmalesgroup,na.rm=TRUE)
    prevbaseM_former <- as.data.frame(formerprevbaseM,row.names= c(startingyear:endingyear))
    prevpolicyM_former<- as.data.frame(formerprevpolicyM,row.names= c(startingyear:endingyear))
    
    # Females
    smokprevbaseF <- colSums(smokpopbaseFgroup, na.rm=TRUE)/colSums(popfemalesgroup,na.rm=TRUE) 
    smokprevpolicyF <- colSums(smokpoppolicyFgroup, na.rm=TRUE)/colSums(popfemalesgroup,na.rm=TRUE) 
    prevbaseF <- as.data.frame(smokprevbaseF,row.names= c(startingyear:endingyear))
    prevpolicyF<- as.data.frame(smokprevpolicyF,row.names= c(startingyear:endingyear))
    
    formerprevbaseF <- colSums(formerpopbaseFgroup, na.rm=TRUE)/colSums(popfemalesgroup,na.rm=TRUE) 
    formerprevpolicyF <- colSums(formerpoppolicyFgroup, na.rm=TRUE)/colSums(popfemalesgroup,na.rm=TRUE) 
    prevbaseF_former <- as.data.frame(formerprevbaseF,row.names= c(startingyear:endingyear))
    prevpolicyF_former<- as.data.frame(formerprevpolicyF,row.names= c(startingyear:endingyear))
    
    # Total population
    smokprevbase <- (colSums(smokpopbaseMgroup, na.rm=TRUE)+colSums(smokpopbaseFgroup,na.rm=TRUE))/colSums(populationgroup,na.rm=TRUE) 
    smokprevpolicy <- (colSums(smokpoppolicyMgroup, na.rm=TRUE)+colSums(smokpoppolicyFgroup, na.rm=TRUE))/colSums(populationgroup,na.rm=TRUE)
    prevbase <- as.data.frame(smokprevbase,row.names= c(startingyear:endingyear))
    prevpolicy<- as.data.frame(smokprevpolicy,row.names= c(startingyear:endingyear))
    
    deaths_df = data.frame()
    for (y in startingyear:endingyear){
      deaths_df <- rbind(deaths_df, gettobaccodeaths_agegroup(finalprevs,y,agegroupstart[x],agegroupend[x]))
    }
    names(deaths_df)<- c("tobaccodeathsM_baseline", "tobaccodeathsM_policy", "deathsM_avoided", "tobaccodeathsF_baseline", "tobaccodeathsF_policy", "deathsF_avoided","tobaccodeaths_baseline", "tobaccodeaths_policy", "deaths_avoided")  
    thisagegroup <- cbind(c(startingyear:endingyear),agegroups[x], "ALL", prevbaseM, prevbaseM_former, prevbaseF, prevbaseF_former,prevpolicyM, prevpolicyM_former,prevpolicyF,prevpolicyF_former, prevbase, prevpolicy, deaths_df)
    finalprevs_agegroups <- rbind(finalprevs_agegroups,thisagegroup)
    
  }
  names(finalprevs_agegroups) <- c("year","age","cohort","males_baseline","males_former_baseline","females_baseline","females_former_baseline",
                                   "males_policy","males_former_policy","females_policy","females_former_policy",
                                   "totalprev_baseline","totalprev_policy",
                                   "tobaccodeathsM_baseline", "tobaccodeathsM_policy", "deathsM_avoided",
                                   "tobaccodeathsF_baseline", "tobaccodeathsF_policy", "deathsF_avoided",
                                   "tobaccodeaths_baseline", "tobaccodeaths_policy", "deaths_avoided"                                   
                                   )

  finalprevs <- rbind(finalprevs,finalprevs_agegroups) ### SOMETHING IS WRONG HERE 
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
colnames(finalprevs) = c("year","age","cohort",
                         "males_baseline","males_former_baseline","females_baseline","females_former_baseline",
                         "males_policy","males_former_policy","females_policy","females_former_policy",
                         "totalprev_baseline","totalprev_policy",
                         "tobaccodeathsM_baseline", "tobaccodeathsM_policy", "deathsM_avoided",
                         "tobaccodeathsF_baseline", "tobaccodeathsF_policy", "deathsF_avoided",
                         "tobaccodeaths_baseline", "tobaccodeaths_policy", "deaths_avoided" ,"policy_year")
write.csv(finalprevs, file=paste0('results_w',Iwp,'_r',Ir,'_b',Ib,'_w',pacwp,'_r',pacr, '_b',pacb,'.csv'), row.names=FALSE)
print(paste0('results_w',Iwp,'_r',Ir,'_b',Ib,'_w',pacwp,'_r',pacr, '_b',pacb,'.csv ', 'is ready.'))