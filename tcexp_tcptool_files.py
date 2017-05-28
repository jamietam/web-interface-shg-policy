import os
import csv
import sys

#dirprevs='/home/jamietam/mla_results/prevs/' # Directory contains prevalence files
dirweb = '/home/jamietam/web-interface-shg-policy/'## Directory contains 'Age_effects_male_cleanair_021815.csv', 'Age_effects_female_cleanair_021$
dirresults = '/home/jamietam/tcexp_results/'

initexp_set = [0.00] 
finalexp_set = [0.10,0.20,0.30,0.40,0.50,0.60,0.70,0.80,0.90,1.00] 
#years_set = [2016,2017,2018,2019,2020] ## Year of policy implementation

os.chdir(dirweb) # change to main directory

count=0
totalset = 3
for initexp in initexp_set:
    for finalexp in finalexp_set:
    	scen=(float(initexp), float(finalexp))
        print "scenario: ", scen
	os.system("Rscript generate_tcexp_policy_website_data.R %0.2f %0.2f " % scen)
        count = count+1
        print "results generated for file ", count, " of ", totalset
cmd5 = "mv deaths* results* lyg* "+dirresults
os.system(cmd5) 
print "files moved to ", dirresults
