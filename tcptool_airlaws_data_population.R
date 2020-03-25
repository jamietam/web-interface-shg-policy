#  ------------------------------------------------------------------------
# CREATE CSV FILES FOR SHG POLICY MODULE WEB INTERFACE --------------------
#  ------------------------------------------------------------------------

rm(list = ls())

library(reshape)
library(reshape2)
library(data.table)

#DIR='/Users/rafaelmeza/Documents/web-interface-shg-policy/'
dirs <- read.table(paste0(DIR,"Directories"), sep="=",stringsAsFactors=FALSE)
webdir=dirs[dirs$V1=='dirwebinterface',2]
prevfiles = dirs[dirs$V1=='dirresultsair',2]
mainDir <- dirs[dirs$V1=='diroutputfiles',2]

setwd(webdir)
inputsDir <- webdir

startingyear = 2010
endingyear = 2060 
cohortsize = 1000000
enactpolicy = c(2016,2017,2018,2019,2020) # Select policy years to include in final file
cohorts = c(1970,1980,1990,2000,2010)

Iwp_set =c(0,1)
Ir_set =c(0,1)
Ib_set =c(0,1)
pacwp_set = c(0, 0.25, 0.5, 0.75, 1)
pacr_set = c(0, 0.25, 0.5, 0.75, 1)
pacb_set = c(0, 0.25, 0.5, 0.75, 1)

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
            # Specify airlaws policy parameters
            Iwp=as.numeric(args[1]) ### indicator of workplace policy to be implemented 1-yes, 0-no
            Ir=as.numeric(args[2])  ### indicator of restaurants policy to be implemented 1-yes, 0-no
            Ib=as.numeric(args[3])  ### indicator of bars policy to be implemented 1-yes, 0-no
            pacwp=as.numeric(args[4])  ### percentage already covered by workplace clean air laws
            pacr=as.numeric(args[5])   ### percentage already covered by restaurants clean air laws
            pacb=as.numeric(args[6])   ### percentage already covered by bars clean air laws

            name = paste0('w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2))
            source('make_results_lyg_deaths_files.R', echo=FALSE)
          }  
        }
      }
    }
  }
}

## CREATE SOURCE_DATA DIRECTORY FOR US FILES

system(paste0("mkdir -p ", mainDir,"US/airlaws/deaths"))
system(paste0("mkdir -p ", mainDir,"US/airlaws/lyg"))
system(paste0("mkdir -p ", mainDir,"US/airlaws/results"))

system(paste0("mv deaths_w*_r*_b*.csv ", mainDir,"US/airlaws/deaths"))
system(paste0("mv lyg_w*_r*_b*.csv ", mainDir,"US/airlaws/lyg"))
system(paste0("mv results_w*_r*_b*.csv ", mainDir,"US/airlaws/results"))

## NEXT STEP: Generate state-level files with state_files_airlaws.R 

## Run state-level functions

setwd(webdir)
source('state_files_airlaws.R')

## LOOP THROUGH AND GENERATE STATE LEVEL FILES
allstates <- c("AL","AK", "AZ", "AR", "CA", "CO","CT", "DE", "DC","FL", "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
"MD","MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
"SC", "SD", "TN", "TX", "UT", "VT","VA", "WA","WV","WI", "WY" )

for (i in c(1:length(allstates))){
  createresultsfiles(allstates[i]) # generates the results file for the state specified using the createresultsfile$
  createdeathsfiles(allstates[i]) # generates the deaths file for the state specified
 createlygfiles(allstates[i]) # generates the lyg file for the state specified
}



