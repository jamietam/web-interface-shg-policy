# Update main directory
#mainDir <- "C:/Users/jamietam/Google Drive/TCP Tool state results/"
#inputsDir <- "C:/Users/jamietam/Google Drive/TCP Tool state results/"
mainDir <- "/home/jamietam/source_data/"
inputsDir <- "/home/jamietam/web-interface-shg-policy/"
initexp <- c(0.00,0.10,0.20,0.30,0.40,0.50,0.60,0.70,0.80,0.90)
finalexp <- c(0.10,0.20,0.30,0.40,0.50,0.60,0.70,0.80,0.90,1.00)
#  -----------------------------------------------------------------------
# 1. Generate prevalence results.zip file for a specific state ------------
#  ------------------------------------------------------------------------
createresultsfiles <- function(stateabbrev){
  dir.create(file.path(mainDir, stateabbrev)) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"taxes")) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"taxes","results"))
  setwd(file.path(mainDir))
  for (v1 in initexp) {
    for (v2 in finalexp) {
      args <- c(v1, v2)
      if(sum(args)>1.00) next
      # Specify tax policy parameters
      initprice = as.numeric(args[1]) # initial price per pack
      tax = as.numeric(args[2]) # federal tax increase
      
      # Read in data
      data <- read.csv(paste0(inputsDir,'prevalence2015.csv'),check.names=FALSE,row.names=1)
      state <- read.csv(paste0(mainDir,'US/taxes/results/results_',format(initprice,nsmall=2),'_t',format(tax,nsmall=2),'.csv'),check.names=FALSE,sep=",")
        
      ###### Calculate scaling factors for each age group and sex
      B_BSF18_24<- data[stateabbrev,"18-24"]/ state$both_baseline[(state$year==2015)&(state$age=="18-24")&(state$policy_year==2016)]
      M_BSF18_24<- data[stateabbrev,"18-24m"]/ state$males_baseline[(state$year==2015)&(state$age=="18-24")&(state$policy_year==2016)]
      F_BSF18_24<- data[stateabbrev,"18-24f"]/ state$females_baseline[(state$year==2015)&(state$age=="18-24")&(state$policy_year==2016)]
      
      #25-44 SF:
      B_BSF25_44<- data[stateabbrev,"25-44"]/ state$both_baseline[(state$year==2015)&(state$age=="25-44")&(state$policy_year==2016)]
      M_BSF25_44<- data[stateabbrev,"25-44m"]/ state$males_baseline[(state$year==2015)&(state$age=="25-44")&(state$policy_year==2016)]
      F_BSF25_44<- data[stateabbrev,"25-44f"]/ state$females_baseline[(state$year==2015)&(state$age=="25-44")&(state$policy_year==2016)]
      
      #45-64 SF:
      B_BSF45_64<- data[stateabbrev,"45-64"]/ state$both_baseline[(state$year==2015)&(state$age=="45-64")&(state$policy_year==2016)]
      M_BSF45_64<- data[stateabbrev,"45-64m"]/ state$males_baseline[(state$year==2015)&(state$age=="45-64")&(state$policy_year==2016)]
      F_BSF45_64<- data[stateabbrev,"45-64f"]/ state$females_baseline[(state$year==2015)&(state$age=="45-64")&(state$policy_year==2016)]
      
      #65P SF:
      B_BSF65p<- data[stateabbrev,"65p"]/ state$both_baseline[(state$year==2015)&(state$age=="65p")&(state$policy_year==2016)]
      M_BSF65p<- data[stateabbrev,"65pm"]/ state$males_baseline[(state$year==2015)&(state$age=="65p")&(state$policy_year==2016)]
      F_BSF65p<- data[stateabbrev,"65pf"]/ state$females_baseline[(state$year==2015)&(state$age=="65p")&(state$policy_year==2016)]
      
      #18-99 SF:
      B_BSF18_99<- data[stateabbrev,"18-99"]/ state$both_baseline[(state$year==2015)&(state$age=="18-99")&(state$policy_year==2016)]
      M_BSF18_99<- data[stateabbrev,"18-99m"]/ state$males_baseline[(state$year==2015)&(state$age=="18-99")&(state$policy_year==2016)]
      F_BSF18_99<- data[stateabbrev,"18-99f"]/ state$females_baseline[(state$year==2015)&(state$age=="18-99")&(state$policy_year==2016)]
      
      policyyears <- c(2016:2020)
      #### Using different scaling factor:
      for (y in c(1:length(policyyears))){
        # BY BIRTH COHORT
        #1970 uses 45_64: 
        state$both_baseline[(state$cohort=="1970")&(state$policy_year==policyyears[y])]<- B_BSF45_64 *state$both_baseline[(state$cohort=="1970")&(state$policy_year==policyyears[y])]
        state$both_policy[(state$cohort=="1970")&(state$policy_year==policyyears[y])]<- B_BSF45_64 *state$both_policy[(state$cohort=="1970")&(state$policy_year==policyyears[y])]
        state$males_baseline[(state$cohort=="1970")&(state$policy_year==policyyears[y])]<- M_BSF45_64 *state$males_baseline[(state$cohort=="1970")&(state$policy_year==policyyears[y])]
        state$females_baseline[(state$cohort=="1970")&(state$policy_year==policyyears[y])]<- F_BSF45_64 *state$females_baseline[(state$cohort=="1970")&(state$policy_year==policyyears[y])]
        state$males_policy[(state$cohort=="1970")&(state$policy_year==policyyears[y])]<- M_BSF45_64 *state$males_policy[(state$cohort=="1970")&(state$policy_year==policyyears[y])]
        state$females_policy[(state$cohort=="1970")&(state$policy_year==policyyears[y])]<- F_BSF45_64 *state$females_policy[(state$cohort=="1970")&(state$policy_year==policyyears[y])]
        
        #1980 uses 45_64
        state$both_baseline[(state$cohort=="1980")&(state$policy_year==policyyears[y])]<- B_BSF45_64 *state$both_baseline[(state$cohort=="1980")&(state$policy_year==policyyears[y])]
        state$both_policy[(state$cohort=="1980")&(state$policy_year==policyyears[y])]<- B_BSF45_64 *state$both_policy[(state$cohort=="1980")&(state$policy_year==policyyears[y])]
        state$males_baseline[(state$cohort=="1980")&(state$policy_year==policyyears[y])]<- M_BSF45_64 *state$males_baseline[(state$cohort=="1980")&(state$policy_year==policyyears[y])]
        state$females_baseline[(state$cohort=="1980")&(state$policy_year==policyyears[y])]<- F_BSF45_64 *state$females_baseline[(state$cohort=="1980")&(state$policy_year==policyyears[y])]
        state$males_policy[(state$cohort=="1980")&(state$policy_year==policyyears[y])]<- M_BSF45_64 *state$males_policy[(state$cohort=="1980")&(state$policy_year==policyyears[y])]
        state$females_policy[(state$cohort=="1980")&(state$policy_year==policyyears[y])]<- F_BSF45_64 *state$females_policy[(state$cohort=="1980")&(state$policy_year==policyyears[y])]
        
        #1990 uses 25_44
        state$both_baseline[(state$cohort=="1990")&(state$policy_year==policyyears[y])]<- B_BSF25_44 *state$both_baseline[(state$cohort=="1990")&(state$policy_year==policyyears[y])]
        state$both_policy[(state$cohort=="1990")&(state$policy_year==policyyears[y])]<- B_BSF25_44 *state$both_policy[(state$cohort=="1990")&(state$policy_year==policyyears[y])]
        state$males_baseline[(state$cohort=="1990")&(state$policy_year==policyyears[y])]<- M_BSF25_44 *state$males_baseline[(state$cohort=="1990")&(state$policy_year==policyyears[y])]
        state$females_baseline[(state$cohort=="1990")&(state$policy_year==policyyears[y])]<- F_BSF25_44 *state$females_baseline[(state$cohort=="1990")&(state$policy_year==policyyears[y])]
        state$males_policy[(state$cohort=="1990")&(state$policy_year==policyyears[y])]<- M_BSF25_44 *state$males_policy[(state$cohort=="1990")&(state$policy_year==policyyears[y])]
        state$females_policy[(state$cohort=="1990")&(state$policy_year==policyyears[y])]<- F_BSF25_44 *state$females_policy[(state$cohort=="1990")&(state$policy_year==policyyears[y])]
        
        #2000 uses 18_24
        state$both_baseline[(state$cohort=="2000")&(state$policy_year==policyyears[y])]<- B_BSF18_24 *state$both_baseline[(state$cohort=="2000")&(state$policy_year==policyyears[y])]
        state$both_policy[(state$cohort=="2000")&(state$policy_year==policyyears[y])]<- B_BSF18_24 *state$both_policy[(state$cohort=="2000")&(state$policy_year==policyyears[y])]
        state$males_baseline[(state$cohort=="2000")&(state$policy_year==policyyears[y])]<- M_BSF18_24 *state$males_baseline[(state$cohort=="2000")&(state$policy_year==policyyears[y])]
        state$females_baseline[(state$cohort=="2000")&(state$policy_year==policyyears[y])]<- F_BSF18_24 *state$females_baseline[(state$cohort=="2000")&(state$policy_year==policyyears[y])]
        state$males_policy[(state$cohort=="2000")&(state$policy_year==policyyears[y])]<- M_BSF18_24 *state$males_policy[(state$cohort=="2000")&(state$policy_year==policyyears[y])]
        state$females_policy[(state$cohort=="2000")&(state$policy_year==policyyears[y])]<- F_BSF18_24 *state$females_policy[(state$cohort=="2000")&(state$policy_year==policyyears[y])]
        
        #2010 uses 18_24
        state$both_baseline[(state$cohort=="2010")&(state$policy_year==policyyears[y])]<- B_BSF18_24 *state$both_baseline[(state$cohort=="2010")&(state$policy_year==policyyears[y])]
        state$both_policy[(state$cohort=="2010")&(state$policy_year==policyyears[y])]<- B_BSF18_24 *state$both_policy[(state$cohort=="2010")&(state$policy_year==policyyears[y])]
        state$males_baseline[(state$cohort=="2010")&(state$policy_year==policyyears[y])]<- M_BSF18_24 *state$males_baseline[(state$cohort=="2010")&(state$policy_year==policyyears[y])]
        state$females_baseline[(state$cohort=="2010")&(state$policy_year==policyyears[y])]<- F_BSF18_24 *state$females_baseline[(state$cohort=="2010")&(state$policy_year==policyyears[y])]
        state$males_policy[(state$cohort=="2010")&(state$policy_year==policyyears[y])]<- M_BSF18_24 *state$males_policy[(state$cohort=="2010")&(state$policy_year==policyyears[y])]
        state$females_policy[(state$cohort=="2010")&(state$policy_year==policyyears[y])]<- F_BSF18_24 *state$females_policy[(state$cohort=="2010")&(state$policy_year==policyyears[y])]
        
        #NONE Birth Cohorts - use age group specific Scaling factors
        # Assume same scaling factors for ages 12-17 as for ages 18-24
        state$both_baseline[(state$age=="12-17")&(state$policy_year==policyyears[y])]<-B_BSF18_24*state$both_baseline[(state$age=="12-17")&(state$policy_year==policyyears[y])]
        state$both_baseline[(state$age=="18-24")&(state$policy_year==policyyears[y])]<-B_BSF18_24*state$both_baseline[(state$age=="18-24")&(state$policy_year==policyyears[y])]
        state$both_baseline[(state$age=="25-44")&(state$policy_year==policyyears[y])]<-B_BSF25_44*state$both_baseline[(state$age=="25-44")&(state$policy_year==policyyears[y])]
        state$both_baseline[(state$age=="45-64")&(state$policy_year==policyyears[y])]<-B_BSF45_64*state$both_baseline[(state$age=="45-64")&(state$policy_year==policyyears[y])]
        state$both_baseline[(state$age=="65p")&(state$policy_year==policyyears[y])]<-B_BSF65p*state$both_baseline[(state$age=="65p")&(state$policy_year==policyyears[y])]
        state$both_baseline[(state$age=="18-99")&(state$policy_year==policyyears[y])]<- B_BSF18_99 *state$both_baseline[(state$age=="18-99")&(state$policy_year==policyyears[y])]
        
        state$males_baseline[(state$age=="12-17")&(state$policy_year==policyyears[y])]<-M_BSF18_24*state$males_baseline[(state$age=="12-17")&(state$policy_year==policyyears[y])]
        state$males_baseline[(state$age=="18-24")&(state$policy_year==policyyears[y])]<-M_BSF18_24*state$males_baseline[(state$age=="18-24")&(state$policy_year==policyyears[y])]
        state$males_baseline[(state$age=="25-44")&(state$policy_year==policyyears[y])]<-M_BSF25_44*state$males_baseline[(state$age=="25-44")&(state$policy_year==policyyears[y])]
        state$males_baseline[(state$age=="45-64")&(state$policy_year==policyyears[y])]<-M_BSF45_64*state$males_baseline[(state$age=="45-64")&(state$policy_year==policyyears[y])]
        state$males_baseline[(state$age=="65p")&(state$policy_year==policyyears[y])]<-M_BSF65p*state$males_baseline[(state$age=="65p")&(state$policy_year==policyyears[y])]
        state$males_baseline[(state$age=="18-99")&(state$policy_year==policyyears[y])]<-M_BSF18_99*state$males_baseline[(state$age=="18-99")&(state$policy_year==policyyears[y])]
        
        state$females_baseline[(state$age=="12-17")&(state$policy_year==policyyears[y])]<-F_BSF18_24*state$females_baseline[(state$age=="12-17")&(state$policy_year==policyyears[y])]
        state$females_baseline[(state$age=="18-24")&(state$policy_year==policyyears[y])]<-F_BSF18_24*state$females_baseline[(state$age=="18-24")&(state$policy_year==policyyears[y])]
        state$females_baseline[(state$age=="25-44")&(state$policy_year==policyyears[y])]<-F_BSF25_44*state$females_baseline[(state$age=="25-44")&(state$policy_year==policyyears[y])]
        state$females_baseline[(state$age=="45-64")&(state$policy_year==policyyears[y])]<-F_BSF45_64*state$females_baseline[(state$age=="45-64")&(state$policy_year==policyyears[y])]
        state$females_baseline[(state$age=="65p")&(state$policy_year==policyyears[y])]<-F_BSF65p*state$females_baseline[(state$age=="65p")&(state$policy_year==policyyears[y])]
        state$females_baseline[(state$age=="18-99")&(state$policy_year==policyyears[y])]<-F_BSF18_99*state$females_baseline[(state$age=="18-99")&(state$policy_year==policyyears[y])]
        
        state$both_policy[(state$age=="12-17")&(state$policy_year==policyyears[y])]<-B_BSF18_24*state$both_policy[(state$age=="12-17")&(state$policy_year==policyyears[y])]
        state$both_policy[(state$age=="18-24")&(state$policy_year==policyyears[y])]<-B_BSF18_24*state$both_policy[(state$age=="18-24")&(state$policy_year==policyyears[y])]
        state$both_policy[(state$age=="25-44")&(state$policy_year==policyyears[y])]<-B_BSF25_44*state$both_policy[(state$age=="25-44")&(state$policy_year==policyyears[y])]
        state$both_policy[(state$age=="45-64")&(state$policy_year==policyyears[y])]<-B_BSF45_64*state$both_policy[(state$age=="45-64")&(state$policy_year==policyyears[y])]
        state$both_policy[(state$age=="65p")&(state$policy_year==policyyears[y])]<-B_BSF65p*state$both_policy[(state$age=="65p")&(state$policy_year==policyyears[y])]
        state$both_policy[(state$age=="18-99")&(state$policy_year==policyyears[y])]<- B_BSF18_99 *state$both_policy[(state$age=="18-99")&(state$policy_year==policyyears[y])]
        
        state$males_policy[(state$age=="12-17")&(state$policy_year==policyyears[y])]<-M_BSF18_24*state$males_policy[(state$age=="12-17")&(state$policy_year==policyyears[y])]
        state$males_policy[(state$age=="18-24")&(state$policy_year==policyyears[y])]<-M_BSF18_24*state$males_policy[(state$age=="18-24")&(state$policy_year==policyyears[y])]
        state$males_policy[(state$age=="25-44")&(state$policy_year==policyyears[y])]<-M_BSF25_44*state$males_policy[(state$age=="25-44")&(state$policy_year==policyyears[y])]
        state$males_policy[(state$age=="45-64")&(state$policy_year==policyyears[y])]<-M_BSF45_64*state$males_policy[(state$age=="45-64")&(state$policy_year==policyyears[y])]
        state$males_policy[(state$age=="65p")&(state$policy_year==policyyears[y])]<-M_BSF65p*state$males_policy[(state$age=="65p")&(state$policy_year==policyyears[y])]
        state$males_policy[(state$age=="18-99")&(state$policy_year==policyyears[y])]<-M_BSF18_99*state$males_policy[(state$age=="18-99")&(state$policy_year==policyyears[y])]
        
        state$females_policy[(state$age=="12-17")&(state$policy_year==policyyears[y])]<-F_BSF18_24*state$females_policy[(state$age=="12-17")&(state$policy_year==policyyears[y])]
        state$females_policy[(state$age=="18-24")&(state$policy_year==policyyears[y])]<-F_BSF18_24*state$females_policy[(state$age=="18-24")&(state$policy_year==policyyears[y])]
        state$females_policy[(state$age=="25-44")&(state$policy_year==policyyears[y])]<-F_BSF25_44*state$females_policy[(state$age=="25-44")&(state$policy_year==policyyears[y])]
        state$females_policy[(state$age=="45-64")&(state$policy_year==policyyears[y])]<-F_BSF45_64*state$females_policy[(state$age=="45-64")&(state$policy_year==policyyears[y])]
        state$females_policy[(state$age=="65p")&(state$policy_year==policyyears[y])]<-F_BSF65p*state$females_policy[(state$age=="65p")&(state$policy_year==policyyears[y])]
        state$females_policy[(state$age=="18-99")&(state$policy_year==policyyears[y])]<-F_BSF18_99*state$females_policy[(state$age=="18-99")&(state$policy_year==policyyears[y])]
      }
      write.csv(state, file=paste0(mainDir,stateabbrev,'/taxes/results/','results_',format(initprice,nsmall=2),'_t',format(tax,nsmall=2),'.csv'), row.names=FALSE)
    }}
  return(paste0("results .csv files generated for ",stateabbrev))
}

#  ------------------------------------------------------------------------
# 2. Generate deaths file for a specific state ------------------------
#  ------------------------------------------------------------------------
createdeathsfiles <- function(stateabbrev){
  dir.create(file.path(mainDir, stateabbrev)) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"taxes")) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"taxes","deaths"))
  setwd(file.path(mainDir))
  for (v1 in initexp) {
    for (v2 in finalexp) {
      args <- c(v1, v2)
      if(sum(args)>1.00) next
      # Specify tax policy parameters
      initprice = as.numeric(args[1]) # initial price per pack
      tax = as.numeric(args[2]) # federal tax increase
      
      # Read in data
      data <- read.csv(paste0(inputsDir,'popsizes.csv'),check.names=FALSE,row.names=1)
      state <- read.csv(paste0(mainDir,'US/taxes/deaths/deaths_',format(initprice,nsmall=2),'_t',format(tax,nsmall=2),'.csv'),check.names=FALSE,sep=",")

      # Calculate scaling factors for each age group and sex
      B_SF<- as.numeric(as.character(data[stateabbrev,"Both"]))/ as.numeric(as.character(data["US","Both"]))
      M_SF<- as.numeric(as.character(data[stateabbrev,"Male"]))/ as.numeric(as.character(data["US","Male"]))
      F_SF<- as.numeric(as.character(data[stateabbrev,"Female"]))/ as.numeric(as.character(data["US","Female"]))
      
      state$deaths_avoided_both<-B_SF*state$deaths_avoided_both
      state$deaths_avoided_males<-M_SF*state$deaths_avoided_males
      state$deaths_avoided_females<-F_SF*state$deaths_avoided_females
      
      write.csv(state, file=paste0(mainDir,stateabbrev,'/taxes/deaths/','deaths_',format(initprice,nsmall=2),'_t',format(tax,nsmall=2),'.csv'), row.names=FALSE)
      }}
  return(paste0("deaths .csv files generated for ",stateabbrev))
}

#  ------------------------------------------------------------------------
# 2. Generate lyg file for a specific state ------------------------
#  ------------------------------------------------------------------------
createlygfiles <- function(stateabbrev){
  dir.create(file.path(mainDir, stateabbrev)) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"taxes")) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"taxes","lyg"))
  setwd(file.path(mainDir))
  for (v1 in initexp) {
    for (v2 in finalexp) {
      args <- c(v1, v2)
      if(sum(args)>1.00) next
      # Specify tax policy parameters
      initprice = as.numeric(args[1]) # initial price per pack
      tax = as.numeric(args[2]) # federal tax increase

      # Read in data
      data <- read.csv(paste0(inputsDir,'popsizes.csv'),row.names=1,check.names=FALSE)
      state <- read.csv(paste0(mainDir,'US/taxes/lyg/lyg_',format(initprice,nsmall=2),'_t',format(tax,nsmall=2),'.csv'),check.names=FALSE,sep=",")

      # Calculate scaling factors for each age group and sex
      B_SF<- as.numeric(as.character(data[stateabbrev,"Both"]))/ as.numeric(as.character(data["US","Both"]))
      M_SF<- as.numeric(as.character(data[stateabbrev,"Male"]))/ as.numeric(as.character(data["US","Male"]))
      F_SF<- as.numeric(as.character(data[stateabbrev,"Female"]))/ as.numeric(as.character(data["US","Female"]))
      
      state$cLYG_both<-B_SF*state$cLYG_both
      state$cLYG_males<-M_SF*state$cLYG_males
      state$cLYG_females<-F_SF*state$cLYG_females
      write.csv(state, file=paste0(mainDir,stateabbrev,'/taxes/lyg/','lyg_',format(initprice,nsmall=2),'_t',format(tax,nsmall=2),'.csv'), row.names=FALSE)
      }}
  return(paste0("lyg .csv files generated for ",stateabbrev))
}
#  ------------------------------------------------------------------------
#  3. Loop through all 50 states + DC -------------------------------------
#  ------------------------------------------------------------------------

allstates <- c("AL","AK", "AZ", "AR", "CA", "CO","CT", "DE", "DC","FL", "GA","HI","ID","IL","IN","IA","KS","KY","LA",
                "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR",
                "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT","VA", "WA","WV","WI", "WY" )

for (i in c(1:length(allstates))){
  createresultsfiles(allstates[i]) # generates the results file for the state specified using the createresultsfile function
  createdeathsfiles(allstates[i]) # generates the deaths file for the state specified 
  createlygfiles(allstates[i]) # generates the lyg file for the state specified 
}
# 
#createresultsfiles("AL")
#createdeathsfiles("AL")
#createlygfiles("AL")
