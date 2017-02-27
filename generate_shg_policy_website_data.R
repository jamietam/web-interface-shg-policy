rm(list = ls())

#  ------------------------------------------------------------------------
# CREATE RESULTS AND DEATHS FILES FOR SHG POLICY MODULE WEB INTERFACE -----
#  ------------------------------------------------------------------------
library(reshape)
library(data.table)

args <- commandArgs(trailingOnly = TRUE)
# args = c(1,1,1,0,0,0,0)

# Specify clean air policy parameters
Iwp=as.numeric(args[1]) ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir=as.numeric(args[2])  ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib=as.numeric(args[3])  ### indicator of bars policy to be implemented 1-yes, 0-no
pacwp=as.numeric(args[4])  ### percentage already covered by workplace clean air laws
pacr=as.numeric(args[5])   ### percentage already covered by restaurants clean air laws
pacb=as.numeric(args[6])   ### percentage already covered by bars clean air laws
iter = as.numeric(args[7])
enactpolicy = c(2016,2017,2018,2019,2020) # Select policy years to include in final file
setwd(paste0("/home/jamietam/scenarios_parallel_",iter,sep=""))

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

# Specify age groups to examine
agegroups = c('12-17','18-24','25-44','45-64','65p','18-99')
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

# -------------------------------------------------------------------------
# Functions to generate prevalence results for each year ------------------
# -------------------------------------------------------------------------
# Generate Total smoking prevalences combining both genders ---------------
smokerprevs <- function(age,year,smokpopbaseM,smokpoppolicyM,smokpopbaseF,smokpoppolicyF,population){ ## Ages 0-99, Years 2010-2060
  baseline_smkprev <- (smokpopbaseM[age+1,year-2009] + smokpopbaseF[age+1,year-2009])/population[age+1,year-2009]
  policy_smkprev <- (smokpoppolicyM[age+1,year-2009] + smokpoppolicyF[age+1,year-2009])/population[age+1,year-2009]       
  return(c(baseline_smkprev, policy_smkprev))
}

# Multiply census population by age-specific prevalences ----------
populationcountsbyprev <- function(pop, scenario){
  thispopscenariogender <- matrix(ncol=ncol(pop),nrow=nrow(pop)) 
  for (x in 1:ncol(pop)){
    for (y in 1:nrow(pop)) {
      z <- as.numeric(pop[y,x])%o% as.numeric(scenario[y,x])
      thispopscenariogender[y,x] <- z
    }
  }
  return(thispopscenariogender)
}
# Create final prevalences dataframe
createresultsfile <- function(finalprevs,policy_year,smokpopbaseM,formerpopbaseM,smokpoppolicyM,formerpoppolicyM,smokpopbaseF,formerpopbaseF,smokpoppolicyF,formerpoppolicyF){

  for(row in 1:length(finalprevs$age)) { 
    finalprevs$both_baseline[row] <- round(smokerprevs(finalprevs$age[row], finalprevs$year[row],smokpopbaseM,smokpoppolicyM,smokpopbaseF,smokpoppolicyF,population)[1],4)
    finalprevs$both_policy[row] <- round(smokerprevs(finalprevs$age[row], finalprevs$year[row],smokpopbaseM,smokpoppolicyM,smokpopbaseF,smokpoppolicyF,population)[2],4)    
  }
  finalprevs$males_baseline <- round(finalprevs$males_baseline,4)
  finalprevs$females_baseline	<- round(finalprevs$females_baseline,4)
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
  names(finalprevs_agegroups) <- c("year","age","cohort","males_baseline","males_former_baseline","females_baseline","females_former_baseline",
                                   "males_policy","males_former_policy","females_policy","females_former_policy",
                                   "both_baseline","both_policy")
  finalprevs <- subset(finalprevs, finalprevs$cohort==1970 | finalprevs$cohort==1980 | finalprevs$cohort==1990 | finalprevs$cohort==2000 | finalprevs$cohort==2010)
  finalprevs <- rbind(finalprevs,finalprevs_agegroups) 
  limitvars <- c("year","age","cohort","males_baseline","females_baseline","males_policy","females_policy","both_baseline","both_policy")
  finalprevs <- finalprevs[limitvars]
  finalprevs$policy_year <- policy_year
  return(finalprevs)
}

# -------------------------------------------------------------------------
# Functions to generate death counts for each year ------------------------
# -------------------------------------------------------------------------
# Get cumulative death count by year --------------------------------------
getcumulativedeaths <- function(dataframe,specifyyear){
  theseyearsonly <- dataframe[dataframe$year<=specifyyear,] 
  deaths <- colSums(theseyearsonly[c("tobaccodeathsM_baseline", "tobaccodeathsM_policy", 
                                     "deaths_avoided_males","tobaccodeathsF_baseline","tobaccodeathsF_policy",
                                     "deaths_avoided_females","tobaccodeaths_baseline","tobaccodeaths_policy","deaths_avoided")], na.rm = TRUE)
  return(deaths)
}
# Create death counts dataframe 
createdeathsfile <- function(policy_year,smokpopbaseM,formerpopbaseM,smokpoppolicyM,formerpoppolicyM,smokpopbaseF,formerpopbaseF,smokpoppolicyF,formerpoppolicyF){
  deaths_df = data.frame()
  for (y in startingyear:endingyear){
    temp = data.frame()
    for (a in 1:length(ages)){
      tobaccodeathsM_baseline <- as.integer(tobaccodeaths_males_current[a,y-2009]*smokpopbaseM[a,y-2009] + tobaccodeaths_males_former[a,y-2009]*formerpopbaseM[a,y-2009])
      tobaccodeathsM_policy <- as.integer(tobaccodeaths_males_current[a,y-2009]*smokpoppolicyM[a,y-2009] + tobaccodeaths_males_former[a,y-2009]*formerpoppolicyM[a,y-2009])
      deaths_avoided_males <- tobaccodeathsM_baseline-tobaccodeathsM_policy
      
      tobaccodeathsF_baseline <- as.integer(tobaccodeaths_females_current[a,y-2009]*smokpopbaseF[a,y-2009] + tobaccodeaths_females_former[a,y-2009]*formerpopbaseF[a,y-2009])
      tobaccodeathsF_policy <- as.integer(tobaccodeaths_females_current[a,y-2009]*smokpoppolicyF[a,y-2009] + tobaccodeaths_females_former[a,y-2009]* formerpoppolicyF[a,y-2009])
      deaths_avoided_females <- tobaccodeathsF_baseline-tobaccodeathsF_policy
      
      tobaccodeaths_baseline <- tobaccodeathsM_baseline+tobaccodeathsF_baseline
      tobaccodeaths_policy <- tobaccodeathsM_policy+tobaccodeathsF_policy
      deaths_avoided <- tobaccodeaths_baseline-tobaccodeaths_policy
      temp = rbind(temp, c(tobaccodeathsM_baseline,tobaccodeathsM_policy,deaths_avoided_males,tobaccodeathsF_baseline,tobaccodeathsF_policy,deaths_avoided_females,tobaccodeaths_baseline,tobaccodeaths_policy,deaths_avoided))
      names(temp)<- c("tobaccodeathsM_baseline", "tobaccodeathsM_policy", "deaths_avoided_males", "tobaccodeathsF_baseline", "tobaccodeathsF_policy", "deaths_avoided_females","tobaccodeaths_baseline", "tobaccodeaths_policy", "deaths_avoided") 
      
    }
    deaths <- colSums(temp)
    deaths_df <- rbind(deaths_df)
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
  return(deaths_df)
}


#  ------------------------------------------------------------------------
# Write final prevalences dataframes to CSV -------------------------------
#  ------------------------------------------------------------------------
for (i in 1:length(enactpolicy)){
  prevalencesM <- read.csv(paste0('prevs/prevalences_males_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'_',enactpolicy[i],'.csv'), header=TRUE) # Read in policy module output data
  prevalencesM <- prevalencesM[order(prevalencesM$year,prevalencesM$age),]# Sort by year, age, policy
  prevalencesF <- read.csv(paste0('prevs/prevalences_females_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'_',enactpolicy[i],'.csv'), header=TRUE) 
  prevalencesF <- prevalencesF[order(prevalencesF$year,prevalencesF$age),]# Sort by year, age, policy
  baselineM <- read.csv('baseline_prevalences_males.csv', header=TRUE)
  baselineF <- read.csv('baseline_prevalences_females.csv', header=TRUE)
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
  smokpopbaseM <- populationcountsbyprev(popmales,baselineM) # Baseline scenario, Males - Number of smokers
  formerpopbaseM <- populationcountsbyprev(popmales,baselineM_former) # Baseline scenario, Males - Number of former smokers
  smokpopbaseF <- populationcountsbyprev(popfemales,baselineF) # Baseline scenario, Females - Number of smokers
  formerpopbaseF <- populationcountsbyprev(popfemales,baselineF_former) # Baseline scenario, Females - Number of former smokers
  smokpoppolicyM <- populationcountsbyprev(popmales,policyM)  # Policy scenario, Males - Number of smokers
  formerpoppolicyM <- populationcountsbyprev(popmales,policyM_former) # Policy scenario, Males - Number of former smokers
  smokpoppolicyF <- populationcountsbyprev(popfemales,policyF) # Policy scenario, Females -  Number of smokers
  formerpoppolicyF <- populationcountsbyprev(popfemales,policyF_former) # Policy scenario, Females -  Number of former smokers
  
  # Call functions to create .csv files -------------------------------------
  finalprevs <- createresultsfile(finalprevs, enactpolicy[i],smokpopbaseM,formerpopbaseM,smokpoppolicyM,formerpoppolicyM,smokpopbaseF,formerpopbaseF,smokpoppolicyF,formerpoppolicyF)
  write.table(finalprevs,paste0('results_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'),col.names=FALSE,row.names=FALSE,sep=',',quote=FALSE,append='TRUE')
  
  deaths_df <- createdeathsfile(enactpolicy[i],smokpopbaseM,formerpopbaseM,smokpoppolicyM,formerpoppolicyM,smokpopbaseF,formerpopbaseF,smokpoppolicyF,formerpoppolicyF)
  write.table(deaths_df,paste0('deaths_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'),col.names=FALSE,row.names=FALSE,sep=',',quote=FALSE,append='TRUE')
  
  print(paste0("policy for the year ", enactpolicy[i], " appended to files"))
}

# Add header row
finalprevs <- read.csv(paste0('results_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'), header=FALSE)
deaths_df <- read.csv(paste0('deaths_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'), header=FALSE)

colnames(finalprevs) <- c("year","age","cohort","males_baseline","females_baseline","males_policy","females_policy","both_baseline","both_policy", "policy_year")
colnames(deaths_df) <- c("year", "deaths_avoided_males", "deaths_avoided_females", "deaths_avoided_both", "policy_year" ) # these are cumulative death counts

write.csv(finalprevs, file=paste0('results_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'), row.names=FALSE)
print(paste0('results_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv ', 'is ready.'))

write.csv(deaths_df, file=paste0('deaths_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'), row.names=FALSE)
print(paste0('deaths_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv ', 'is ready.'))

