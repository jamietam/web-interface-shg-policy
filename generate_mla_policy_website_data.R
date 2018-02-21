#  ------------------------------------------------------------------------
# CREATE CSV FILES FOR SHG POLICY MODULE WEB INTERFACE --------------------
#  ------------------------------------------------------------------------
library(reshape)
library(data.table)

# For local testing
args = c(21 ,0.00,0.00)
prevfiles = 'C:/Users/jamietam/Dropbox/Github/web-interface-shg-policy/'
mla_age=as.numeric(args[1])
pac19=as.numeric(args[2])
pac21 = as.numeric(args[3])
setwd("C:/Users/jamietam/Dropbox/Github/web-interface-shg-policy/")

# # Specify policy parameters
# args <- commandArgs(trailingOnly = TRUE)
# mla_age=as.numeric(args[1])
# pac19=as.numeric(args[2])
# pac21 = as.numeric(args[3])
# setwd("/home/jamietam/web-interface-shg-policy/")
# prevfiles = '/home/jamietam/mla_results/prevs/'

name = paste0(format(mla_age),'_pac19_',format(pac19,nsmall=2),'_pac21_',format(pac21,nsmall=2))
enactpolicy = c(2016,2017,2018,2019,2020) # Select policy years to include in final file
cohorts = c(2000,2010,2020)
startingyear = 2010
endingyear = 2100

source('make_results_lyg_deaths_files.R', echo=FALSE)
