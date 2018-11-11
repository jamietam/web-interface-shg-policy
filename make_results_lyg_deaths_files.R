popmales <- read.csv(paste0("censusdata/censuspop_males_",endingyear,".csv"),header=TRUE) # Read in Census data
popmales <- popmales[,-1] # Remove 1st column "ages"
popfemales <- read.csv(paste0("censusdata/censuspop_females_",endingyear,".csv"),header=TRUE)
popfemales <- popfemales[,-1] # Remove 1st column "ages"
population <- read.csv(paste0("censusdata/censuspopulation_total_",endingyear,".csv"),header=TRUE)
population <- population[,-1] # Remove 1st column "ages"

acm_males_current <- read.csv(paste0("acmratesbysmokingstatus/acm_males_current_",endingyear,".csv"),header=TRUE) # Read in death rates
a <-  1-exp(-acm_males_current) # transform rates to probabilities
acm_males_current[,2:52] <- a[,2:52] # replace rates with probabilities
acm_males_former <- read.csv(paste0("acmratesbysmokingstatus/acm_males_former_",endingyear,".csv"),header=TRUE)
a <-  1-exp(-acm_males_former) 
acm_males_former[,2:52] <- a[,2:52] 
acm_males_never <- read.csv(paste0("acmratesbysmokingstatus/acm_males_never_",endingyear,".csv"),header=TRUE)
a <-  1-exp(-acm_males_never) 
acm_males_never[,2:52] <- a[,2:52] 
acm_females_current <- read.csv(paste0("acmratesbysmokingstatus/acm_females_current_",endingyear,".csv"),header=TRUE)
a <-  1-exp(-acm_females_current) 
acm_females_current[,2:52] <- a[,2:52] 
acm_females_former <- read.csv(paste0("acmratesbysmokingstatus/acm_females_former_",endingyear,".csv"),header=TRUE)
a <-  1-exp(-acm_females_former) 
acm_females_former[,2:52] <- a[,2:52] 
acm_females_never <- read.csv(paste0("acmratesbysmokingstatus/acm_females_never_",endingyear,".csv"),header=TRUE)
a <-  1-exp(-acm_females_never) 
acm_females_never[,2:52] <- a[,2:52]

tobaccodeaths_males_current <- acm_males_current[,-1] - acm_males_never[,-1]
tobaccodeaths_males_former <- acm_males_former[,-1] - acm_males_never[,-1]
tobaccodeaths_females_current <- acm_females_current[,-1] - acm_females_never[,-1]
tobaccodeaths_females_former <- acm_females_former[,-1] - acm_females_never[,-1]

male_LE_ns<-read.csv(paste0('acmratesbysmokingstatus/MaleNeverLE_2010to',endingyear,'.csv'),header=TRUE) # Read in life expectancies
female_LE_ns<-read.csv(paste0('acmratesbysmokingstatus/FemaleNeverLE_2010to',endingyear,'.csv'),header=TRUE)

agegroups = c('12-17','18-24','25-44','45-64','65p','18-99') # Specify age groups to examine
agegroupstart = c(12,18,25,45,65,18)
agegroupend = c(17,24,44,64,99,99)

ages = NULL
for (i in 0:99) {
  ages = rbind(ages, paste("pop_",i,sep=""))
}
years = NULL
for (i in startingyear:endingyear){
  years = rbind(years, paste("yr",i,sep=""))
}
yrs=NULL
for (i in startingyear:endingyear){
  yrs = rbind(yrs, paste0(i,sep=""))
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
                df <- subset(df, select=yrs)
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
                       df <- subset(df, select=yrs)
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
    finalprevs$both_baseline[row] <- smokerprevs(finalprevs$age[row], finalprevs$year[row],smokpopbaseM,smokpoppolicyM,smokpopbaseF,smokpoppolicyF,population)[1]
    finalprevs$both_policy[row] <- smokerprevs(finalprevs$age[row], finalprevs$year[row],smokpopbaseM,smokpoppolicyM,smokpopbaseF,smokpoppolicyF,population)[2]    
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
    
    thisagegroup <- cbind(c(startingyear:endingyear),agegroups[x], "ALL", prevbaseM, prevbaseM_former, prevbaseF, prevbaseF_former,prevpolicyM, prevpolicyM_former,prevpolicyF,prevpolicyF_former, prevbase, prevpolicy)
    finalprevs_agegroups <- rbind(finalprevs_agegroups,thisagegroup)
    
  }
  #   finalprevs_agegroups <- subset(finalprevs_agegroups,finalprevs_agegroups)
  names(finalprevs_agegroups) <- c("year","age","cohort","males_baseline","males_former_baseline","females_baseline","females_former_baseline",
                                   "males_policy","males_former_policy","females_policy","females_former_policy",
                                   "both_baseline","both_policy")
  finalprevs <- subset(finalprevs, cohort %in% cohorts) 
  finalprevs <- rbind(finalprevs,finalprevs_agegroups) 
  finalprevs <- cbind(finalprevs[,1:3], round(finalprevs[,4:13],8))
  finalprevs$policy_year <- policy_year
  
  # Create death counts dataframe -------------------------------------------
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
  deaths_df$policy_year <- policy_year
  deaths_df$cohort <- "ALL"
  
  # Create cohort death counts dataframe ------------------------------------
  
  cohortdeaths_df = data.frame()
  for (c in cohorts){
    for (y in startingyear:endingyear){
      # cohort age is calendar year - birth year
      a = ifelse(y - c<100, y-c,NA) #replace values greater than 99 with NA
      if (y==c){
        tobaccodeathsM_baseline <- 0
        tobaccodeathsM_policy <- 0
        
        tobaccodeathsF_baseline <-0
        tobaccodeathsF_policy <- 0
      }
      else {
        tobaccodeathsM_baseline <- as.integer(tobaccodeaths_males_current[a,y-2009]*smokpopbaseM[a,y-2009] + tobaccodeaths_males_former[a,y-2009]*formerpopbaseM[a,y-2009])
        tobaccodeathsM_policy <- as.integer(tobaccodeaths_males_current[a,y-2009]*smokpoppolicyM[a,y-2009] + tobaccodeaths_males_former[a,y-2009]*formerpoppolicyM[a,y-2009])
        
        tobaccodeathsF_baseline <- as.integer(tobaccodeaths_females_current[a,y-2009]*smokpopbaseF[a,y-2009] + tobaccodeaths_females_former[a,y-2009]*formerpopbaseF[a,y-2009])
        tobaccodeathsF_policy <- as.integer(tobaccodeaths_females_current[a,y-2009]*smokpoppolicyF[a,y-2009] + tobaccodeaths_females_former[a,y-2009]*formerpoppolicyF[a,y-2009])
      }
      tobaccodeaths_baseline <- tobaccodeathsM_baseline+tobaccodeathsF_baseline
      tobaccodeaths_policy <- tobaccodeathsM_policy+tobaccodeathsF_policy
      deaths_avoided_males <- tobaccodeathsM_baseline-tobaccodeathsM_policy
      deaths_avoided_females <- tobaccodeathsF_baseline-tobaccodeathsF_policy
      deaths_avoided <- tobaccodeaths_baseline-tobaccodeaths_policy
      cohortdeaths_df = rbind(cohortdeaths_df, c(y, c,tobaccodeathsM_baseline,tobaccodeathsM_policy,deaths_avoided_males,tobaccodeathsF_baseline,tobaccodeathsF_policy,deaths_avoided_females,tobaccodeaths_baseline,tobaccodeaths_policy,deaths_avoided))
      
    }
  }
  names(cohortdeaths_df)<- c("year","cohort",
                             "tobaccodeathsM_baseline", "tobaccodeathsM_policy", "deaths_avoided_males",
                             "tobaccodeathsF_baseline", "tobaccodeathsF_policy", "deaths_avoided_females",
                             "tobaccodeaths_baseline", "tobaccodeaths_policy", "deaths_avoided")
  deaths_df_cohorts = data.frame()
  for (c in cohorts){
    cohorttemp = subset(cohortdeaths_df, cohort==c)
    for (r in 1:nrow(cohorttemp)){
      cohorttemp$cumulativedeathsM_baseline[r] <- getcumulativedeaths(cohorttemp, cohorttemp$year[r])[1]
      cohorttemp$cumulativedeathsM_policy[r] <- getcumulativedeaths(cohorttemp, cohorttemp$year[r])[2]
      cohorttemp$cumulativedeaths_avoided_males[r] <- getcumulativedeaths(cohorttemp, cohorttemp$year[r])[3]
      
      cohorttemp$cumulativedeathsF_baseline[r] <- getcumulativedeaths(cohorttemp, cohorttemp$year[r])[4]
      cohorttemp$cumulativedeathsF_policy[r] <- getcumulativedeaths(cohorttemp, cohorttemp$year[r])[5]
      cohorttemp$cumulativedeaths_avoided_females[r] <- getcumulativedeaths(cohorttemp, cohorttemp$year[r])[6]
      
      cohorttemp$cumulativedeaths_baseline[r] <- getcumulativedeaths(cohorttemp, cohorttemp$year[r])[7]
      cohorttemp$cumulativedeaths_policy[r] <- getcumulativedeaths(cohorttemp, cohorttemp$year[r])[8]
      cohorttemp$cumulativedeaths_avoided_both[r] <- getcumulativedeaths(cohorttemp, cohorttemp$year[r])[9]  
    } 
    deaths_df_cohorts = rbind(deaths_df_cohorts,cohorttemp)
  }
  deaths_df_cohorts$policy_year <- policy_year
  deaths_df <- rbind(deaths_df_cohorts,deaths_df)
  
  # Create life years gained dataframe --------------------------------------
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
  lyg$policy_year <- policy_year
  lyg$cohort <- "ALL"
  
  # Create cohort lyg dataframe ------------------------------------
  
  cohortdeaths_lyg = data.frame()
  for (c in cohorts){
    for (y in startingyear:endingyear){
      # cohort age is calendar year - birth year
      a = ifelse(y - c<100, y-c,NA) #replace values greater than 99 with NA
      if (y==c){
        yll_baselineM <- 0
        yll_policyM <- 0
        
        yll_baselineF <-0
        yll_policyF <- 0
      }
      else {
        yll_baselineM <- as.integer(tobaccodeaths_males_current[a,y-2009]*smokpopbaseM[a,y-2009]*male_LE_ns[a,y-2009] + tobaccodeaths_males_former[a,y-2009]*formerpopbaseM[a,y-2009]*male_LE_ns[a,y-2009])
        yll_policyM <- as.integer(tobaccodeaths_males_current[a,y-2009]*smokpoppolicyM[a,y-2009]*male_LE_ns[a,y-2009] + tobaccodeaths_males_former[a,y-2009]*formerpoppolicyM[a,y-2009]*male_LE_ns[a,y-2009])
        
        yll_baselineF <- as.integer(tobaccodeaths_females_current[a,y-2009]*smokpopbaseF[a,y-2009]*female_LE_ns[a,y-2009] + tobaccodeaths_females_former[a,y-2009]*formerpopbaseF[a,y-2009]*female_LE_ns[a,y-2009])
        yll_policyF <- as.integer(tobaccodeaths_females_current[a,y-2009]*smokpoppolicyF[a,y-2009]*female_LE_ns[a,y-2009] + tobaccodeaths_females_former[a,y-2009]*formerpoppolicyF[a,y-2009]*female_LE_ns[a,y-2009])
      }
      yll_baseline <- yll_baselineM+yll_baselineF
      yll_policy <- yll_policyM+yll_policyF
      lyg_males <- yll_baselineM -yll_policyM
      lyg_females <- yll_baselineF - yll_policyF
      lyg_both <- yll_baseline-yll_policy
      
      cohortdeaths_lyg = rbind(cohortdeaths_lyg, c(y, c, yll_baselineM, yll_policyM, lyg_males, yll_baselineF, yll_policyF, lyg_females, yll_baseline, yll_policy, lyg_both))
    }
  }
  names(cohortdeaths_lyg)<- c("year","cohort", "yll_baselineM", "yll_policyM", "lyg_males", "yll_baselineF", "yll_policyF", "lyg_females",
                              "yll_baseline", "yll_policy", "lyg_both")
  lyg_df_cohorts = data.frame()
  for (c in cohorts){
    cohortlyg = subset(cohortdeaths_lyg, cohort==c)
    for (r in 1:nrow(cohorttemp)){
      cohortlyg$cumulativeM_baseline[r] <- getcumulativelifeyears(cohortlyg, cohortlyg$year[r])[1]
      cohortlyg$cumulativeM_policy[r] <- getcumulativelifeyears(cohortlyg, cohortlyg$year[r])[2]
      cohortlyg$cumulativeLYG_males[r] <- getcumulativelifeyears(cohortlyg, cohortlyg$year[r])[3]
      
      cohortlyg$cumulativeF_baseline[r] <- getcumulativelifeyears(cohortlyg, cohortlyg$year[r])[4]
      cohortlyg$cumulativeF_policy[r] <- getcumulativelifeyears(cohortlyg, cohortlyg$year[r])[5]
      cohortlyg$cumulativeLYG_females[r] <- getcumulativelifeyears(cohortlyg, cohortlyg$year[r])[6]
      
      cohortlyg$cumulative_baseline[r] <- getcumulativelifeyears(cohortlyg, cohortlyg$year[r])[7]
      cohortlyg$cumulative_policy[r] <- getcumulativelifeyears(cohortlyg, cohortlyg$year[r])[8]
      cohortlyg$cumulativeLYG_both[r] <- getcumulativelifeyears(cohortlyg, cohortlyg$year[r])[9]
      
    } 
    lyg_df_cohorts = rbind(lyg_df_cohorts,cohortlyg)
  }
  lyg_df_cohorts$policy_year <- policy_year
  lyg <- rbind(lyg_df_cohorts,lyg)
  
  finalprevs <- finalprevs[c("year","age","cohort","males_baseline","females_baseline","males_policy","females_policy","both_baseline","both_policy","policy_year")]
  deaths_df <- deaths_df[c("year","cohort", "cumulativedeaths_avoided_males", "cumulativedeaths_avoided_females", "policy_year")]
  lyg <- lyg[c("year","cohort", "cumulativeLYG_males", "cumulativeLYG_females","policy_year")]
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
  
  baselineM <- read.csv(paste0('baseline_prevalences_males_',endingyear,'_',format(cohortsize, scientific=FALSE),'.csv'), header=TRUE)
  baselineF <- read.csv(paste0('baseline_prevalences_females_',endingyear,'_',format(cohortsize, scientific=FALSE),'.csv'), header=TRUE)
  
  dfs <- createresultsfile(prevalencesM,prevalencesF,baselineM,baselineF,enactpolicy[i])
  
  write.table(dfs[1],paste0('results_',name,'.csv'),col.names=FALSE,row.names=FALSE,sep=',',quote=FALSE,append='TRUE')
  write.table(dfs[2],paste0('deaths_',name,'.csv'),col.names=FALSE,row.names=FALSE,sep=',',quote=FALSE,append='TRUE')
  write.table(dfs[3],paste0('lyg_',name,'.csv'),col.names=FALSE,row.names=FALSE,sep=',',quote=FALSE,append='TRUE')
  
  print(paste0("policy for the year ", enactpolicy[i], " appended to files"))
}

lifeyearsgained <- read.csv(paste0('lyg_',name,'.csv'),header=FALSE) 
finalprevs <- read.csv(paste0('results_',name,'.csv'), header=FALSE)
deaths_df <- read.csv(paste0('deaths_',name,'.csv'), header=FALSE)

colnames(lifeyearsgained) <- c("year","cohort", "cLYG_males", "cLYG_females", "policy_year")
colnames(deaths_df) <- c("year", "cohort", "deaths_avoided_males", "deaths_avoided_females", "policy_year" )

colnames(finalprevs) <- c("year","age","cohort","males_baseline","females_baseline","males_policy","females_policy","both_baseline","both_policy", "policy_year")

write.csv(lifeyearsgained, file=paste0('lyg_',name,'.csv'), row.names=FALSE)
print(paste0('lyg_',name,'.csv', ' is ready.'))

write.csv(finalprevs, file=paste0('results_',name,'.csv'), row.names=FALSE)
print(paste0('results_',name,'.csv', ' is ready.'))

write.csv(deaths_df, file=paste0('deaths_',name,'.csv'), row.names=FALSE)
print(paste0('deaths_',name,'.csv', ' is ready.'))
