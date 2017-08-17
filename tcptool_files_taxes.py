import os
import csv
import sys

#dirprevs='/home/jamietam/mla_results/prevs/' # Directory contains prevalence files
dirweb = '/home/jamietam/web-interface-shg-policy/'## Directory contains 'Age_effects_male_cleanair_021815.csv', 'Age_effects_female_cleanair_021$
dirresults = '/home/jamietam/tax_results/'

initprice_set = [4.00] 
tax_set = [0.00] 
#years_set = [2016,2017,2018,2019,2020] ## Year of policy implementation

os.chdir(dirweb) # change to main directory

count=0
totalset = 3
for initprice in initprice_set:
    for tax in tax_set:
    	scen=(float(initprice), float(tax))
        print "scenario: ", scen
	os.system("Rscript generate_tax_policy_website_data.R %0.2f %0.2f " % scen)
        count = count+1
        print "results generated for file ", count, " of ", totalset
cmd5 = "mv deaths* results* lyg* "+dirresults
os.system(cmd5) 
print "files moved to ", dirresults
