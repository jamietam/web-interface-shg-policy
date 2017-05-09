#  ------------------------------------------------------------------------
# CREATE CSV FILES FOR SHG POLICY MODULE WEB INTERFACE --------------------
#  ------------------------------------------------------------------------
library(reshape)
library(data.table)

# For local testing
# args = c(19 ,0.00,0.00)
# prevfiles = 'C:/Users/jamietam/Dropbox/CISNET/policy_module/mla/prevs/'
# mla_age=as.numeric(args[1])
# pac19=as.numeric(args[2])
# pac21 = as.numeric(args[3])
# setwd("C:/Users/jamietam/Dropbox/Github/web-interface-shg-policy/")

# # Specify policy parameters
args <- commandArgs(trailingOnly = TRUE)
mla_age=as.numeric(args[1])
pac19=as.numeric(args[2])
pac21 = as.numeric(args[3])
setwd("/home/jamietam/web-interface-shg-policy/")
prevfiles = '/home/jamietam/mla_results/prevs/'

name = paste0(format(mla_age),'_pac19_',format(pac19,nsmall=2),'_pac21_',format(pac21,nsmall=2))
enactpolicy = c(2016,2017,2018,2019,2020) # Select policy years to include in final file

popmales <- read.csv("censusdata/censuspop_males.csv",header=TRUE) # Read in Census data
popmales <- popmales[,-1] # Remove 1st column "ages"
popfemales <- read.csv("censusdata/censuspop_females.csv",header=TRUE)
popfemales <- popfemales[,-1] # Remove 1st column "ages"
population <- read.csv("censusdata/censuspopulation_total.csv",header=TRUE)
population <- population[,-1] # Remove 1st column "ages"

acm_males_current <- read.csv("acmratesbysmokingstatus/acm_males_current.csv",header=TRUE) # Read in death rates
a <-  1-exp(-acm_males_current) # transform rates to probabilities
acm_males_current[,2:52] <- a[,2:52] # replace rates with probabilities
acm_males_former <- read.csv("acmratesbysmokingstatus/acm_males_former.csv",header=TRUE)
a <-  1-exp(-acm_males_former) 
acm_males_former[,2:52] <- a[,2:52] 
acm_males_never <- read.csv("acmratesbysmokingstatus/acm_males_never.csv",header=TRUE)
a <-  1-exp(-acm_males_never) 
acm_males_never[,2:52] <- a[,2:52] 
acm_females_current <- read.csv("acmratesbysmokingstatus/acm_females_current.csv",header=TRUE)
a <-  1-exp(-acm_females_current) 
acm_females_current[,2:52] <- a[,2:52] 
acm_females_former <- read.csv("acmratesbysmokingstatus/acm_females_former.csv",header=TRUE)
a <-  1-exp(-acm_females_former) 
acm_females_former[,2:52] <- a[,2:52] 
acm_females_never <- read.csv("acmratesbysmokingstatus/acm_females_never.csv",header=TRUE)
a <-  1-exp(-acm_females_never) 
acm_females_never[,2:52] <- a[,2:52]

tobaccodeaths_males_current <- acm_males_current[,-1] - acm_males_never[,-1]
tobaccodeaths_males_former <- acm_males_former[,-1] - acm_males_never[,-1]
tobaccodeaths_females_current <- acm_females_current[,-1] - acm_females_never[,-1]
tobaccodeaths_females_former <- acm_females_former[,-1] - acm_females_never[,-1]

male_LE_ns<-read.csv('acmratesbysmokingstatus/MaleNeverLE_2010to2060.csv',header=TRUE) # Read in life expectancies
female_LE_ns<-read.csv('acmratesbysmokingstatus/FemaleNeverLE_2010to2060.csv',header=TRUE)

agegroups = c('12-17','18-24','25-44','45-64','65p','18-99') # Specify age groups to examine
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

smokerprevs <- function(age,year,smokpopbaseM,smokpoppolicyM,smokpopbaseF,smokpoppolicyF,population){ # Generate Total smoking prevalences combining both genders
  baseline_smkprev <- (smokpopbaseM[age+1,year-2009] + smokpopbaseF[age+1,year-2009])/population[age+1,year-2009] 
  policy_smkprev <- (smokpoppolicyM[age+1,year-2009] + smokpoppolicyF[age+1,year-2009])/population[age+1,year-2009]       
  return(c(baseline_smkprev, policy_smkprev))
}

getcumulativedeaths <- function(dataframe,specifyyear){ # Get cumulative death count by year
  theseyearsonly <- dataframe[dataframe$year<=specifyyear,] 
  deaths <- colSums(theseyearsonly[c("tobaccodeathsM_baseline", "tobaccodeathsM_policy", 
                                     "deaths_avoided_males","tobaccodeathsF_baseline","tobaccodeathsF_policy",
                                     "deaths_avoided_females","tobaccodeaths_baseline","tobaccodeaths_policy","deaths_avoided")], na.rm = TRUE)
  return(deaths)
}

getcumulativelifeyears <- function(dataframe,specifyyear){ # Get cumulative lifeyear count by year
  theseyearsonly <- dataframe[dataframe$year<=specifyyear,] 
  deaths <- colSums(theseyearsonly[c("yll_baselineM", "yll_policyM", "lyg_males", "yll_baselineF", "yll_policyF", "lyg_females",
                                     "yll_baseline", "yll_policy", "lyg_both")], na.rm = TRUE)
  return(deaths)
}
#  ------------------------------------------------------------------------
# Function to generate results for each year ------------------------------
#  ------------------------------------------------------------------------
createresultsfile <- function(prevalencesM, prevalencesF, baselineM, baselineF, policy_year){
  # Split policy module output into baseline and policy scenarios -----------
  baselineM <- baselineM[(baselineM$year>=startingyear & baselineM$year<=endingyear),] 
  baselineF <- baselineF[(baselineF$year>=startingyear & baselineF$year<=endingyear),] 
  policyM <- prevalencesM[(prevalencesM$year>=startingyear & prevalencesM$year<=endingyear),]
  policyF <- prevalencesF[(prevalencesF$year>=startingyear & prevalencesF$year<=endingyear),]
  
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
  
  smokpopbaseM <- matrix(ncol=ncol(popmales),nrow=nrow(popmales))    # Baseline scenario, Males - Number of smokers
  for (x in 1:ncol(popmales)){
    for (y in 1:nrow(popmales)) {
      z <- as.numeric(popmales[y,x])%o% as.numeric(baselineM[y,x])
      smokpopbaseM[y,x] <- z
    }
  }

  formerpopbaseM <- matrix(ncol=ncol(popmales),nrow=nrow(popmales))   # Baseline scenario, Males - Number of former smokers
  for (x in 1:ncol(popmales)){
    for (y in 1:nrow(popmales)) {
      z <- as.numeric(popmales[y,x])%o% as.numeric(baselineM_former[y,x])
      formerpopbaseM[y,x] <- z
    }
  }
  
  smokpopbaseF <- matrix(ncol=ncol(popfemales),nrow=nrow(popfemales))   # Baseline scenario, Females - Number of smokers
  for (x in 1:ncol(popfemales)){
    for (y in 1:nrow(popfemales)) {
      z <- as.numeric(popfemales[y,x])%o% as.numeric(baselineF[y,x])
      smokpopbaseF[y,x] <- z
    }
  }

  formerpopbaseF <- matrix(ncol=ncol(popfemales),nrow=nrow(popfemales))   # Baseline scenario, Females - Number of former smokers
  for (x in 1:ncol(popfemales)){
    for (y in 1:nrow(popfemales)) {
      z <- as.numeric(popfemales[y,x])%o% as.numeric(baselineF_former[y,x])
      formerpopbaseF[y,x] <- z
    }
  }
  
  smokpoppolicyM <- matrix(ncol=ncol(popmales),nrow=nrow(popmales))   # Policy scenario, Males - Number of smokers
  for (x in 1:ncol(popmales)){
    for (y in 1:nrow(popmales)) {
      z <- as.numeric(popmales[y,x])%o% as.numeric(policyM[y,x])
      smokpoppolicyM[y,x] <- z
    }
  }
  
  formerpoppolicyM <- matrix(ncol=ncol(popmales),nrow=nrow(popmales))   # Policy scenario, Males - Number of former smokers
  for (x in 1:ncol(popmales)){
    for (y in 1:nrow(popmales)) {
      z <- as.numeric(popmales[y,x])%o% as.numeric(policyM_former[y,x])
      formerpoppolicyM[y,x] <- z
    }
  }

  smokpoppolicyF <- matrix(ncol=ncol(popfemales),nrow=nrow(popfemales))   # Policy scenario, Females -  Number of smokers
  for (x in 1:ncol(popfemales)){
    for (y in 1:nrow(popfemales)) {
      z <- as.numeric(popfemales[y,x])%o% as.numeric(policyF[y,x])
      smokpoppolicyF[y,x] <- z
    }
  }

  formerpoppolicyF <- matrix(ncol=ncol(popfemales),nrow=nrow(popfemales))   # Policy scenario, Females -  Number of former smokers
  for (x in 1:ncol(popfemales)){
    for (y in 1:nrow(popfemales)) {
      z <- as.numeric(popfemales[y,x])%o% as.numeric(policyF_former[y,x])
      formerpoppolicyF[y,x] <- z
    }
  }  
  for(row in 1:length(finalprevs$age)) { 
    finalprevs$both_baseline[row] <- round(smokerprevs(finalprevs$age[row], finalprevs$year[row],smokpopbaseM,smokpoppolicyM,smokpopbaseF,smokpoppolicyF,population)[1],4)
    finalprevs$both_policy[row] <- round(smokerprevs(finalprevs$age[row], finalprevs$year[row],smokpopbaseM,smokpoppolicyM,smokpopbaseF,smokpoppolicyF,population)[2],4)    
  }
  finalprevs$males_baseline <- round(finalprevs$males_baseline,4)
  finalprevs$females_baseline  <- round(finalprevs$females_baseline,4)
  finalprevs$males_policy	<- round(finalprevs$males_policy,4)
  finalprevs$females_policy <- round(finalprevs$females_policy,4)
  
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
    
    thisagegroup <- cbind(c(startingyear:endingyear),agegroups[x], "ALL", round(prevbaseM,4), round(prevbaseM_former,4), round(prevbaseF,4), round(prevbaseF_former,4),round(prevpolicyM,4), round(prevpolicyM_former,4),round(prevpolicyF,4),round(prevpolicyF_former,4), round(prevbase,4), round(prevpolicy,4))
    finalprevs_agegroups <- rbind(finalprevs_agegroups,thisagegroup)
    
  }
  #   finalprevs_agegroups <- subset(finalprevs_agegroups,finalprevs_agegroups)
  names(finalprevs_agegroups) <- c("year","age","cohort","males_baseline","males_former_baseline","females_baseline","females_former_baseline",
                                   "males_policy","males_former_policy","females_policy","females_former_policy",
                                   "both_baseline","both_policy")
  finalprevs <- subset(finalprevs, finalprevs$cohort==1970 | finalprevs$cohort==1980 | finalprevs$cohort==1990 | finalprevs$cohort==2000 | finalprevs$cohort==2010)
  finalprevs <- rbind(finalprevs,finalprevs_agegroups) 
  limitvars <- c("year","age","cohort","males_baseline","females_baseline","males_policy","females_policy","both_baseline","both_policy")
  finalprevs <- finalprevs[limitvars]
  finalprevs$policy_year <- policy_year
  
  # Create death counts dataframe
  deaths_df = data.frame()
  for (y in startingyear:endingyear){
    temp = data.frame()
    for (a in 1:length(ages)){
      tobaccodeathsM_baseline <- as.integer(tobaccodeaths_males_current[a,y-2009]*smokpopbaseM[a,y-2009] + tobaccodeaths_males_former[a,y-2009]*formerpopbaseM[a,y-2009])
      tobaccodeathsM_policy <- as.integer(tobaccodeaths_males_current[a,y-2009]*smokpoppolicyM[a,y-2009] + tobaccodeaths_males_former[a,y-2009]*formerpoppolicyM[a,y-2009])
      deaths_avoided_males <- tobaccodeathsM_baseline-tobaccodeathsM_policy
      
      tobaccodeathsF_baseline <- as.integer(tobaccodeaths_females_current[a,y-2009]*smokpopbaseF[a,y-2009] + tobaccodeaths_females_former[a,y-2009]*formerpopbaseF[a,y-2009])
      tobaccodeathsF_policy <- as.integer(tobaccodeaths_females_current[a,y-2009]*smokpoppolicyF[a,y-2009] + tobaccodeaths_females_former[a,y-2009]*formerpoppolicyF[a,y-2009])
      deaths_avoided_females <- tobaccodeathsF_baseline-tobaccodeathsF_policy
      
      tobaccodeaths_baseline <- tobaccodeathsM_baseline+tobaccodeathsF_baseline
      tobaccodeaths_policy <- tobaccodeathsM_policy+tobaccodeathsF_policy
      deaths_avoided <- tobaccodeaths_baseline-tobaccodeaths_policy
      temp = rbind(temp, c(tobaccodeathsM_baseline,tobaccodeathsM_policy,deaths_avoided_males,tobaccodeathsF_baseline,tobaccodeathsF_policy,deaths_avoided_females,tobaccodeaths_baseline,tobaccodeaths_policy,deaths_avoided))
    }
    deaths <- colSums(temp)
    deaths_df <- rbind(deaths_df, c(y,deaths))
  }
  names(deaths_df)<- c("year","tobaccodeathsM_baseline", "tobaccodeathsM_policy", "deaths_avoided_males", "tobaccodeathsF_baseline", "tobaccodeathsF_policy", "deaths_avoided_females",
                       "tobaccodeaths_baseline", "tobaccodeaths_policy", "deaths_avoided") 
  for (r in 1:nrow(deaths_df)){
    deaths_df$cumulativedeathsM_baseline[r] <- getcumulativedeaths(deaths_df, deaths_df$year[r])[1]
    deaths_df$cumulativedeathsM_policy[r] <- getcumulativedeaths(deaths_df, deaths_df$year[r])[2]
    deaths_df$cumulativedeaths_avoided_males[r] <- getcumulativedeaths(deaths_df, deaths_df$year[r])[3]
    
    deaths_df$cumulativedeathsF_baseline[r] <- getcumulativedeaths(deaths_df, deaths_df$year[r])[4]
    deaths_df$cumulativedeathsF_policy[r] <- getcumulativedeaths(deaths_df, deaths_df$year[r])[5]
    deaths_df$cumulativedeaths_avoided_females[r] <- getcumulativedeaths(deaths_df, deaths_df$year[r])[6]
    
    deaths_df$cumulativedeaths_baseline[r] <- getcumulativedeaths(deaths_df, deaths_df$year[r])[7]
    deaths_df$cumulativedeaths_policy[r] <- getcumulativedeaths(deaths_df, deaths_df$year[r])[8]
    deaths_df$cumulativedeaths_avoided_both[r] <- getcumulativedeaths(deaths_df, deaths_df$year[r])[9]  
  } 
  
  lessvars <- c("year","cumulativedeaths_avoided_males", "cumulativedeaths_avoided_females", "cumulativedeaths_avoided_both")
  deaths_df <- deaths_df[lessvars]
  deaths_df$policy_year <- policy_year
  
  # Create life years gained dataframe
  lyg = data.frame()
  for (y in startingyear:endingyear){
    temp = data.frame()
    for (a in 1:length(ages)){
      yll_baselineM <- as.integer(tobaccodeaths_males_current[a,y-2009]*smokpopbaseM[a,y-2009]*male_LE_ns[a,y-2009] + tobaccodeaths_males_former[a,y-2009]*formerpopbaseM[a,y-2009]*male_LE_ns[a,y-2009])
      yll_policyM <- as.integer(tobaccodeaths_males_current[a,y-2009]*smokpoppolicyM[a,y-2009]*male_LE_ns[a,y-2009] + tobaccodeaths_males_former[a,y-2009]*formerpoppolicyM[a,y-2009]*male_LE_ns[a,y-2009])
      lyg_males <- yll_baselineM -yll_policyM
      
      yll_baselineF <- as.integer(tobaccodeaths_females_current[a,y-2009]*smokpopbaseF[a,y-2009]*female_LE_ns[a,y-2009] + tobaccodeaths_females_former[a,y-2009]*formerpopbaseF[a,y-2009]*female_LE_ns[a,y-2009])
      yll_policyF <- as.integer(tobaccodeaths_females_current[a,y-2009]*smokpoppolicyF[a,y-2009]*female_LE_ns[a,y-2009] + tobaccodeaths_females_former[a,y-2009]*formerpoppolicyF[a,y-2009]*female_LE_ns[a,y-2009])
      lyg_females <- yll_baselineF - yll_policyF
      
      yll_baseline <- yll_baselineM+yll_baselineF
      yll_policy <- yll_policyM+yll_policyF
      lyg_both <- yll_baseline-yll_policy
      temp = rbind(temp, c(yll_baselineM, yll_policyM, lyg_males, yll_baselineF, yll_policyF, lyg_females, yll_baseline, yll_policy, lyg_both))
    }
    lifeyears <- colSums(temp)
    lyg <- rbind(lyg, c(y,lifeyears))
  }
  names(lyg)<- c("year","yll_baselineM", "yll_policyM", "lyg_males", "yll_baselineF", "yll_policyF", "lyg_females",
                       "yll_baseline", "yll_policy", "lyg_both") 
  for (r in 1:nrow(lyg)){
    lyg$cumulativeM_baseline[r] <- getcumulativelifeyears(lyg, lyg$year[r])[1]
    lyg$cumulativeM_policy[r] <- getcumulativelifeyears(lyg, lyg$year[r])[2]
    lyg$cumulativeLYG_males[r] <- getcumulativelifeyears(lyg, lyg$year[r])[3]
    
    lyg$cumulativeF_baseline[r] <- getcumulativelifeyears(lyg, lyg$year[r])[4]
    lyg$cumulativeF_policy[r] <- getcumulativelifeyears(lyg, lyg$year[r])[5]
    lyg$cumulativeLYG_females[r] <- getcumulativelifeyears(lyg, lyg$year[r])[6]
    
    lyg$cumulative_baseline[r] <- getcumulativelifeyears(lyg, lyg$year[r])[7]
    lyg$cumulative_policy[r] <- getcumulativelifeyears(lyg, lyg$year[r])[8]
    lyg$cumulativeLYG_both[r] <- getcumulativelifeyears(lyg, lyg$year[r])[9]  
  } 
  
  lessvars <- c("year","cumulativeLYG_males", "cumulativeLYG_females", "cumulativeLYG_both")
  lyg <- lyg[lessvars]
  lyg$policy_year <- policy_year
  
  list_dfs <- list(finalprevs,deaths_df,lyg)
  return(list_dfs)
}

#  ------------------------------------------------------------------------
# Write final dataframes to CSV -------------------------------------------
#  ------------------------------------------------------------------------
for (i in 1:length(enactpolicy)){
  prevalencesM <- read.csv(paste0(prevfiles,'prevalences_males_',name,'_',enactpolicy[i],'.csv'), header=TRUE) # Read in policy module output data
  prevalencesM <- prevalencesM[order(prevalencesM$year,prevalencesM$age),]# Sort by year, age, policy
  prevalencesF <- read.csv(paste0(prevfiles,'prevalences_females_',name,'_',enactpolicy[i],'.csv'), header=TRUE)
  prevalencesF <- prevalencesF[order(prevalencesF$year,prevalencesF$age),]# Sort by year, age, policy
  
  baselineM <- read.csv('baseline_prevalences_males.csv', header=TRUE)
  baselineF <- read.csv('baseline_prevalences_females.csv', header=TRUE)
  
  dfs <- createresultsfile(prevalencesM,prevalencesF,baselineM,baselineF,enactpolicy[i])
  
  write.table(dfs[1],paste0('results_',name,'.csv'),col.names=FALSE,row.names=FALSE,sep=',',quote=FALSE,append='TRUE')
  write.table(dfs[2],paste0('deaths_',name,'.csv'),col.names=FALSE,row.names=FALSE,sep=',',quote=FALSE,append='TRUE')
  write.table(dfs[3],paste0('lyg_',name,'.csv'),col.names=FALSE,row.names=FALSE,sep=',',quote=FALSE,append='TRUE')
  
  print(paste0("policy for the year ", enactpolicy[i], " appended to files"))
}

lifeyearsgained <- read.csv(paste0('lyg_',name,'.csv'),header=FALSE) 
finalprevs <- read.csv(paste0('results_',name,'.csv'), header=FALSE)
deaths_df <- read.csv(paste0('deaths_',name,'.csv'), header=FALSE)

# colnames(lifeyearsgained) <- c("year","yll_baselineM","yll_policyM","lyg_males","yll_baselineF","yll_policyF","lyg_females", "yll_baseline","yll_policy","lyg_both" ,
#                                "cyll_baselineM","cyll_policyM","cLYG_males","cyll_baselineF","cyll_policyF","cLYG_females", "cyll_baseline","cyll_policy","cLYG_both" ,"policy_year")
colnames(lifeyearsgained) <- c("year","cLYG_males", "cLYG_females", "cLYG_both", "policy_year")

colnames(finalprevs) <- c("year","age","cohort","males_baseline","females_baseline","males_policy","females_policy","both_baseline","both_policy", "policy_year")

# colnames(deaths_df)<- c("year","tobdeathsM_baseline", "tobdeathsM_policy", "deaths_avoided_males", "tobdeathsF_baseline", "tobdeathsF_policy", "deaths_avoided_females",
#                      "tobdeaths_baseline", "tobdeaths_policy", "deaths_avoided","cdeathsM_baseline","cdeathsM_policy","cdeaths_avoided_males",
#                      "cdeathsF_baseline","cdeathsF_policy","cdeaths_avoided_females", "cdeaths_baseline", "cdeaths_policy","cdeaths_avoided_both", "policy_year" )

colnames(deaths_df) <- c("year", "deaths_avoided_males", "deaths_avoided_females", "deaths_avoided_both", "policy_year" )

write.csv(lifeyearsgained, file=paste0('lyg_',name,'.csv'), row.names=FALSE)
print(paste0('lyg',name,'.csv', ' is ready.'))

write.csv(finalprevs, file=paste0('results_',name,'.csv'), row.names=FALSE)
print(paste0('results_',name,'.csv', ' is ready.'))

write.csv(deaths_df, file=paste0('deaths_',name,'.csv'), row.names=FALSE)
print(paste0('deaths_',name,'.csv', ' is ready.'))
