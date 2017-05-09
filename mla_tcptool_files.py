import os
import csv
import sys

#dirprevs='/home/jamietam/mla_results/prevs/' # Directory contains prevalence files
dirweb = '/home/jamietam/web-interface-shg-policy/'## Directory contains 'Age_effects_male_cleanair_021815.csv', 'Age_effects_female_cleanair_021$
dirresults = '/home/jamietam/mla_results/'

mla_age_set = [19,21,25] ### indicator of workplace policy to be implemented 1-yes, 0-no
pac19_set = [0.00] ### percentage already covered by restaurants clean air laws
pac21_set = [0.25,0.50,0.75,1.00] ### percentage already covered by bars clean air laws
#years_set = [2016,2017,2018,2019,2020] ## Year of policy implementation

os.chdir(dirweb) # change to main directory

count=0
totalset = 3
for mla_age in mla_age_set:
    for pac19 in pac19_set:
        for pac21 in pac21_set:
            scen=(mla_age, float(pac19), float(pac21))
            print "scenario: ", scen
            os.system("Rscript generate_mla_policy_website_data.R %s %0.2f %0.2f " % scen)
            count = count+1
            print "results generated for file ", count, " of ", totalset
cmd5 = "mv deaths* results* lyg* "+dirresults
os.system(cmd5) 
print "files moved to ", dirresults
