#  ------------------------------------------------------------------------
# CREATE CSV FILES FOR SHG POLICY MODULE WEB INTERFACE --------------------
#  ------------------------------------------------------------------------

rm(list = ls())

library(reshape)
library(data.table)

#DIR='/Users/rafaelmeza/Documents/web-interface-shg-policy/'
dirs <- read.table(paste0(DIR,"Directories"), sep="=",stringsAsFactors=FALSE)
webdir=dirs[dirs$V1=='dirwebinterface',2]
prevfiles = dirs[dirs$V1=='dirresultstcexp',2]
mainDir <- dirs[dirs$V1=='diroutputfiles',2]

setwd(webdir)
inputsDir <- webdir

startingyear = 2010
endingyear = 2060 
cohortsize = 1000000
enactpolicy = c(2016,2017,2018,2019,2020) # Select policy years to include in final file
cohorts = c(1970,1980,1990,2000,2010)

initexp <- c(0.00,0.10,0.20,0.30,0.40,0.50,0.60,0.70,0.80,0.90)
finalexp <- c(0.00,0.10,0.20,0.30,0.40,0.50,0.60,0.70,0.80,0.90,1.00)

for (v1 in initexp) {
  for (v2 in finalexp) {
    if (v1>0 & (v2<=v1)) next #still includes baseline scenario 0.00 to 0.00
    init =as.numeric(v1)
    final = as.numeric(v2)

    name = paste0('initexp',format(init,nsmall=2),'_policyexp',format(final,nsmall=2))
    source('make_results_lyg_deaths_files.R', echo=FALSE)
  }
}

## CREATE SOURCE_DATA DIRECTORY FOR US FILES

system(paste0("mkdir -p ", mainDir,"US/tcexp/deaths"))
system(paste0("mkdir -p ", mainDir,"US/tcexp/lyg"))
system(paste0("mkdir -p ", mainDir,"US/tcexp/results"))

system(paste0("mv deaths_initexp*.csv ", mainDir,"US/tcexp/deaths"))
system(paste0("mv lyg_initexp*.csv ", mainDir,"US/tcexp/lyg"))
system(paste0("mv results_initexp*.csv ", mainDir,"US/tcexp/results"))

## NEXT STEP: Generate state-level files with state_files_tcexp.R

## Run state-level functions

setwd(webdir)
source('state_files_tcexp.R')

# LOOP THROUGH AND GENERATE STATE LEVEL FILES
allstates <- c("AL","AK", "AZ", "AR", "CA", "CO","CT", "DE", "DC","FL", "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
"MD","MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
"SC", "SD", "TN", "TX", "UT", "VT","VA", "WA","WV","WI", "WY" )

for (i in c(1:length(allstates))){
  createresultsfiles(allstates[i]) # generates the results file for the state specified using the createresultsfile$
  createdeathsfiles(allstates[i]) # generates the deaths file for the state specified
 createlygfiles(allstates[i]) # generates the lyg file for the state specified
}

