#  ------------------------------------------------------------------------
# CREATE CSV FILES FOR SHG POLICY MODULE WEB INTERFACE --------------------
#  ------------------------------------------------------------------------
library(reshape)
library(data.table)

# # Specify policy parameters
args <- commandArgs(trailingOnly = TRUE)
Iwp=as.numeric(args[1]) # indicator of workplace policy to be implemented 1-yes, 0-no
Ir=as.numeric(args[2])  # indicator of restaurants policy to be implemented 1-yes, 0-no
Ib=as.numeric(args[3])  # indicator of bars policy to be implemented 1-yes, 0-no
pacwp=as.numeric(args[4])  # percentage already covered by workplace clean air laws
pacr=as.numeric(args[5])   # percentage already covered by restaurants clean air laws
pacb=as.numeric(args[6])   # percentage already covered by bars clean air laws

setwd("/home/jamietam/web-interface-shg-policy/")
prevfiles = '/home/jamietam/cleanair_results/'

name = paste0('w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2))
enactpolicy = c(2016,2017,2018,2019,2020) # Select policy years to include in final file
cohorts = c(1970,1980,1990,2000,2010)
startingyear = 2010
endingyear = 2060 

source('make_results_lyg_deaths_files.R', echo=FALSE)
