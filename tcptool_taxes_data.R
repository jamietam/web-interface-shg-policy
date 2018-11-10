#  ------------------------------------------------------------------------
# CREATE CSV FILES FOR SHG POLICY MODULE WEB INTERFACE --------------------
#  ------------------------------------------------------------------------
library(reshape)
library(data.table)

setwd("/home/jamietam/web-interface-shg-policy/")
prevfiles = '/home/jamietam/taxes_results/prevsSept2018/'
mainDir <- "/home/jamietam/source_dataAug2018/"
inputsDir <- "/home/jamietam/web-interface-shg-policy/"

initprices <- c(4.00,4.50,5.00,5.50,6.00,6.50,7.00,7.50,8.00,8.50,9.00,9.50,10.00,10.50)
taxes <- c(0.00,1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00)

for (v1 in initprices) {
  for (v2 in taxes) {
    if (v1>4.00 & v2==0) next # only run baseline scenario once
    initprice =as.numeric(v1)
    tax = as.numeric(v2)

    name = paste0(format(initprice,nsmall=2),'_t',format(tax,nsmall=2))
    enactpolicy = c(2016,2017,2018,2019,2020) # Select policy years to include in final file
    cohorts = c(1970,1980,1990,2000,2010)
    startingyear = 2010
    endingyear = 2060 
    source('make_results_lyg_deaths_files.R', echo=FALSE)
  }
}

## CREATE SOURCE_DATA DIRECTORY FOR US FILES

system(paste0("mkdir -p ", mainDir,"US/taxes/deaths"))
system(paste0("mkdir -p ", mainDir,"US/taxes/lyg"))
system(paste0("mkdir -p ", mainDir,"US/taxes/results"))

system(paste0("mv deaths_*t*.csv ", mainDir,"US/taxes/deaths"))
system(paste0("mv lyg_*_t*.csv ", mainDir,"US/taxes/lyg"))
system(paste0("mv results_*_t*.csv ", mainDir,"US/taxes/results"))

## NEXT STEP: Generate state-level files with state_files_taxes.R

## Run state-level functions

source('state_files_taxes.R')

# LOOP THROUGH AND GENERATE STATE LEVEL FILES
allstates <- c("AL","AK", "AZ", "AR", "CA", "CO","CT", "DE", "DC","FL", "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
"MD","MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
"SC", "SD", "TN", "TX", "UT", "VT","VA", "WA","WV","WI", "WY" )

for (i in c(1:length(allstates))){
  createresultsfiles(allstates[i]) # generates the results file for the state specified using the createresultsfile$
  createdeathsfiles(allstates[i]) # generates the deaths file for the state specified
 createlygfiles(allstates[i]) # generates the lyg file for the state specified
}



