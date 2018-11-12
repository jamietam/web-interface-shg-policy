#  ------------------------------------------------------------------------
# CREATE CSV FILES FOR SHG POLICY MODULE WEB INTERFACE --------------------
#  ------------------------------------------------------------------------
library(reshape)
library(data.table)

setwd("/home/jamietam/web-interface-shg-policy/")
prevfiles = '/home/jamietam/mla_results/prevsNov2018/'
mainDir <- "/home/jamietam/source_dataNov2018/"
inputsDir <- "/home/jamietam/web-interface-shg-policy/"

startingyear = 2010
endingyear = 2100
cohortsize = 500000
enactpolicy = c(2016,2017,2018,2019,2020)
cohorts = c(2000,2010,2020)

minages <- c(19,21,25)
pac19_set <- c(0.00, 0.25, 0.50, 0.75,1.00)
pac21_set <- c(0.00, 0.25, 0.50, 0.75,1.00)

for (v1 in minages) {
  for (v2 in pac19_set) {
    for (v3 in pac21_set) {
      if ((v2 + v3) > 1.00) next

      mla_age = as.numeric(v1)
      pac19 = as.numeric(v2) 
      pac21 = as.numeric(v3) 

      name = paste0(format(mla_age),'_pac19_',format(pac19,nsmall=2),'_pac21_',format(pac21,nsmall=2))
      source('make_results_lyg_deaths_files.R', echo=FALSE)
    }
  }
}

## CREATE SOURCE_DATA DIRECTORY FOR US FILES

system(paste0("mkdir -p ", mainDir,"US/mla/deaths"))
system(paste0("mkdir -p ", mainDir,"US/mla/lyg"))
system(paste0("mkdir -p ", mainDir,"US/mla/results"))

system(paste0("mv deaths_*pac19_*pac21_*.csv ", mainDir,"US/mla/deaths"))
system(paste0("mv lyg_*pac19_*pac21_*.csv ", mainDir,"US/mla/lyg"))
system(paste0("mv results_*pac19_*pac21_*.csv ", mainDir,"US/mla/results"))

## Run state-level functions

source('state_files_mla.R')

## LOOP THROUGH AND GENERATE STATE LEVEL FILES

allstates <- c("AL","AK", "AZ", "AR", "CA", "CO","CT", "DE", "DC","FL", "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
"MD","MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
"SC", "SD", "TN", "TX", "UT", "VT","VA", "WA","WV","WI", "WY" )

for (i in c(1:length(allstates))){
  createresultsfiles(allstates[i]) # generates the results file for the state specified using the createresultsfile$
  createdeathsfiles(allstates[i]) # generates the deaths file for the state specified
 createlygfiles(allstates[i]) # generates the lyg file for the state specified
}

