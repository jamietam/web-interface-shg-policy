#  ------------------------------------------------------------------------
# CREATE CSV FILES FOR SHG POLICY MODULE WEB INTERFACE --------------------
#  ------------------------------------------------------------------------
library(reshape)
library(data.table)

# # Specify policy parameters
args <- commandArgs(trailingOnly = TRUE)
initexp=as.numeric(args[1])
finalexp=as.numeric(args[2])
setwd("/home/jamietam/web-interface-shg-policy/")
prevfiles = '/home/jamietam/tcexp_results/'

name = paste0('initexp',format(initexp,nsmall=2),'_policyexp',format(finalexp,nsmall=2))
enactpolicy = c(2016,2017,2018,2019,2020) # Select policy years to include in final file
cohorts = c(1970,1980,1990,2000,2010)
startingyear = 2010
endingyear = 2060 

source('make_results_lyg_deaths_files.R', echo=TRUE)