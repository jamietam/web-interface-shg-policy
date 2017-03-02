import os
import csv
import sys

# Run scenarios in parallel and serially within each thread
iter1 = str(0)
print "iteration: ", iter1

dirsim='/home/jamietam/shg-policy-module_parallel_'+iter1+'/' # Directory contains 'policy_shg.py'
dirinputs=dirsim+'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
dirscen = '/home/jamietam/scenarios_parallel_'+iter1+'/'
dirweb = '/home/jamietam/web-interface-shg-policy/'## Directory contains 'Age_effects_male_cleanair_021815.csv', 'Age_effects_female_cleanair_021$
dirresults = '/home/jamietam/mla_results/'

mla_age_set = [19,21,25] ### indicator of workplace policy to be implemented 1-yes, 0-no
pac19_set = [0.25] ### percentage already covered by restaurants clean air laws
pac21_set = [0.00] ### percentage already covered by bars clean air laws
years_set = [2016,2017,2018,2019,2020] ## Year of policy implementation

count=0
totalset = 3
for mla_age in mla_age_set:
    for pac19 in pac19_set:
        for pac21 in pac21_set:
            for year in years_set:
                scen=(mla_age, float(pac19), float(pac21), year)
                print "scenario: ", scen
                os.chdir(dirweb) # change to directory with age effects modifier male and female files
                # Create policy inputs file
                os.system("Rscript Create_MLApolicy_file_WithParams.R %s %0.2f %0.2f %s" % scen)
                # Males
                cmd1="mv inputsmla_males_%s_pac19_%0.2f_pac21_%0.2f_%s.csv " % scen # move file to policy module inputs folder
                cmd1=cmd1+dirinputs+"policies.csv"
                os.system(cmd1)
                os.chdir(dirinputs) 
                os.system("cp demographics_males.csv demographics.csv")
                os.chdir(dirsim)
                os.system("python policy_shg.py") # run policy module
                cmd2="mv prevalences.csv "+dirscen+"prevalences_males_%s_pac19_%0.2f_pac21_%0.2f_%s.csv" % scen
                os.system(cmd2)
                print "male output file saved ", year
                # Females
                os.chdir(dirweb)
                cmd3="mv inputsmla_females_%s_pac19_%0.2f_pac21_%0.2f_%s.csv " % scen
                cmd3=cmd3+dirinputs+"policies.csv"
                os.system(cmd3)
                os.chdir(dirinputs)
                os.system("cp demographics_females.csv demographics.csv")
                os.chdir(dirsim)
                os.system("python policy_shg.py")
                cmd4="mv prevalences.csv "+dirscen+"prevalences_females_%s_pac19_%0.2f_pac21_%0.2f_%s.csv" % scen
                os.system(cmd4)
                print "female output file saved ", year
            params = (mla_age,float(pac19),float(pac21),iter1)
            print "params: ", params[0:3]
            os.chdir(dirweb)
            os.system("Rscript generate_mla_policy_website_data.R %s %0.2f %0.2f %s" % params)
            count = count+1
            print "results generated for file ", count, " of ", totalset
os.chdir(dirscen)
cmd5 = "mv prevalences* deaths* results* "+dirresults
os.system(cmd5) 
print "files moved to ", dirresults
