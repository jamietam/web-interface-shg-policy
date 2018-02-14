#  ------------------------------------------------------------------------
# CREATE CSV FILES FOR SHG POLICY MODULE WEB INTERFACE --------------------
#  ------------------------------------------------------------------------
library(reshape)
library(data.table)

# For local testing
# args = c(5.00 ,2.00)
# prevfiles = 'C:/Users/jamietam/Dropbox/Github/web-interface-shg-policy/taxresults_Dec11/prevs/'
# initprice=as.numeric(args[1])
# tax=as.numeric(args[2])
# setwd("C:/Users/jamietam/Dropbox/Github/web-interface-shg-policy/")

# Specify policy parameters
args <- commandArgs(trailingOnly = TRUE)
initprice=as.numeric(args[1]) ### indicator of workplace policy to be implemented 1-ye
tax=as.numeric(args[2])  ### indicator of restaurants policy to be implemented 1-yes, 
setwd("/home/jamietam/web-interface-shg-policy/")
prevfiles = '/home/jamietam/tax_results/prevs/'

name = paste0(format(initprice,nsmall=2),'_t',format(tax,nsmall=2))
enactpolicy = c(2016,2017,2018,2019,2020) # Select policy years to include in final file
cohorts = c(1970,1980,1990,2000,2010)
startingyear = 2010
endingyear = 2060 

source('make_results_lyg_deaths_files.R', echo=FALSE)
