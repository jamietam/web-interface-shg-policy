# Update main directory
mainDir <- "/home/jamietam/source_dataFeb2018/"
inputsDir <- "/home/jamietam/web-interface-shg-policy/"

Iwp_set =c(0,1)
Ir_set =c(0,1)
Ib_set =c(0,1)
pacwp_set = c(0, 0.25, 0.5, 0.75, 1)
pacr_set = c(0, 0.25, 0.5, 0.75, 1)
pacb_set = c(0, 0.25, 0.5, 0.75, 1)

#  ------------------------------------------------------------------------
# 1. Generate prevalence results.zip file for a specific state ------------
#  ------------------------------------------------------------------------
createresultsfiles <- function(stateabbrev){
  dir.create(file.path(mainDir, stateabbrev)) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"airlaws")) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"airlaws","results"))
  setwd(file.path(mainDir))
  for (v1 in Iwp_set) {
    for (v2 in Ir_set) {
      for(v3 in Ib_set) {
        for (v4 in pacwp_set) {
          for (v5 in pacr_set) {
            for (v6 in pacb_set) {
              args <- c(v1, v2, v3, v4, v5, v6)
	            if (v1==0 & v4>0.00) next
	            if (v2==0 & v5>0.00) next
	            if (v3==0 & v6>0.00) next
              # Specify clean air policy parameters
              Iwp=as.numeric(args[1]) ### indicator of workplace policy to be implemented 1-yes, 0-no
              Ir=as.numeric(args[2])  ### indicator of restaurants policy to be implemented 1-yes, 0-no
              Ib=as.numeric(args[3])  ### indicator of bars policy to be implemented 1-yes, 0-no
              pacwp=as.numeric(args[4])  ### percentage already covered by workplace clean air laws
              pacr=as.numeric(args[5])   ### percentage already covered by restaurants clean air laws
              pacb=as.numeric(args[6])   ### percentage already covered by bars clean air laws
              
              # Read in data
              data <- read.csv(paste0(inputsDir,'prevalence2015.csv'),check.names=FALSE,row.names=1)
              state <- read.csv(paste0('US/airlaws/results/results_w',Iwp,'_r',Ir,'_b',Ib,'_w',
                                       format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'),check.names=FALSE,sep=",")
      
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
              write.csv(state, file=paste0(mainDir,stateabbrev,'/airlaws/results/','results_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'), row.names=FALSE)
      }}}}}}
  return(paste0("results .csv files generated for ",stateabbrev))
}

#  ------------------------------------------------------------------------
# 2. Generate deaths file for a specific state ------------------------
#  ------------------------------------------------------------------------
createdeathsfiles <- function(stateabbrev){
  dir.create(file.path(mainDir, stateabbrev)) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"airlaws")) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"airlaws","deaths"))
  setwd(file.path(mainDir))
  for (v1 in Iwp_set) {
    for (v2 in Ir_set) {
      for(v3 in Ib_set) {
        for (v4 in pacwp_set) {
          for (v5 in pacr_set) {
            for (v6 in pacb_set) {
              args <- c(v1, v2, v3, v4, v5, v6)
              if (v1==0 & v4>0.00) next
              if (v2==0 & v5>0.00) next
              if (v3==0 & v6>0.00) next
              # Specify clean air policy parameters
              Iwp=as.numeric(args[1]) ### indicator of workplace policy to be implemented 1-yes, 0-no
              Ir=as.numeric(args[2])  ### indicator of restaurants policy to be implemented 1-yes, 0-no
              Ib=as.numeric(args[3])  ### indicator of bars policy to be implemented 1-yes, 0-no
              pacwp=as.numeric(args[4])  ### percentage already covered by workplace clean air laws
              pacr=as.numeric(args[5])   ### percentage already covered by restaurants clean air laws
              pacb=as.numeric(args[6])   ### percentage already covered by bars clean air laws
              
              # Read in data
              data <- read.csv(paste0(inputsDir,'popsizes.csv'),check.names=FALSE,row.names=1)
              state <- read.csv(paste0('US/airlaws/deaths/deaths_w',Iwp,'_r',Ir,'_b',Ib,'_w',
                                       format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'),check.names=FALSE,sep=",")
  
              # Calculate scaling factors for each age group and sex
              M_SF<- as.numeric(as.character(data[stateabbrev,"Male"]))/ as.numeric(as.character(data["US","Male"]))
              F_SF<- as.numeric(as.character(data[stateabbrev,"Female"]))/ as.numeric(as.character(data["US","Female"]))
              
              state$deaths_avoided_males<-round(M_SF*state$deaths_avoided_males,2)
              state$deaths_avoided_females<-round(F_SF*state$deaths_avoided_females,2)
              
              write.csv(state, file=paste0(mainDir,stateabbrev,'/airlaws/deaths/','deaths_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'), row.names=FALSE)
      }}}}}}
  return(paste0("deaths .csv files generated for ",stateabbrev))
}

#  ------------------------------------------------------------------------
# 3. Generate lyg file for a specific state ------------------------
#  ------------------------------------------------------------------------
createlygfiles <- function(stateabbrev){
  dir.create(file.path(mainDir, stateabbrev)) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"airlaws")) # create the folder if it does not exist already
  dir.create(file.path(mainDir, stateabbrev,"airlaws","lyg"))
  setwd(file.path(mainDir))
  for (v1 in Iwp_set) {
    for (v2 in Ir_set) {
      for(v3 in Ib_set) {
        for (v4 in pacwp_set) {
          for (v5 in pacr_set) {
            for (v6 in pacb_set) {
              args <- c(v1, v2, v3, v4, v5, v6)
              if (v1==0 & v4>0.00) next
              if (v2==0 & v5>0.00) next
              if (v3==0 & v6>0.00) next          
              # Specify clean air policy parameters
              Iwp=as.numeric(args[1]) ### indicator of workplace policy to be implemented 1-yes, 0-no
              Ir=as.numeric(args[2])  ### indicator of restaurants policy to be implemented 1-yes, 0-no
              Ib=as.numeric(args[3])  ### indicator of bars policy to be implemented 1-yes, 0-no
              pacwp=as.numeric(args[4])  ### percentage already covered by workplace clean air laws
              pacr=as.numeric(args[5])   ### percentage already covered by restaurants clean air laws
              pacb=as.numeric(args[6])   ### percentage already covered by bars clean air laws

              # Read in data
              data <- read.csv(paste0(inputsDir,'popsizes.csv'),row.names=1,check.names=FALSE)
              state <- read.csv(paste0('US/airlaws/lyg/lyg_w',Iwp,'_r',Ir,'_b',Ib,'_w',
                                 format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'),check.names=FALSE,sep=",")

              # Calculate scaling factors for each age group and sex
              M_SF<- as.numeric(as.character(data[stateabbrev,"Male"]))/ as.numeric(as.character(data["US","Male"]))
              F_SF<- as.numeric(as.character(data[stateabbrev,"Female"]))/ as.numeric(as.character(data["US","Female"]))
              
              state$cLYG_males<-round(M_SF*state$cLYG_males,2)
              state$cLYG_females<-round(F_SF*state$cLYG_females,2)
        
              write.csv(state, file=paste0(mainDir,stateabbrev,'/airlaws/lyg/','lyg_w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2),'.csv'), row.names=FALSE)
      }}}}}}
  return(paste0("lyg .csv files generated for ",stateabbrev))
}
#  ------------------------------------------------------------------------
#  4. Loop through all 50 states + DC -------------------------------------
#  ------------------------------------------------------------------------
# allstates <- c("AL","AK", "AZ", "AR", "CA", "CO","CT", "DE", "DC","FL", "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME", "MD", 
# "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
#  "SD", "TN", "TX", "UT", "VT","VA", "WA","WV","WI", "WY" )

#for (i in c(1:length(allstates))){
#  createresultsfiles(allstates[i]) # generates the results file for the state specified using the createresultsfile function
#  createdeathsfiles(allstates[i]) # generates the deaths file for the state specified 
# createlygfiles(allstates[i]) # generates the lyg file for the state specified 
#}
 
createresultsfiles("AL")
createdeathsfiles("AL")
createlygfiles("AL")


