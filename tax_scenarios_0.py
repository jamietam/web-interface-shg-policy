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
dirresults = '/home/jamietam/tax_results/'

initprice_set = [4,5,6] ### initial price per pack
tax_set = [4.50,5.00,5.50,6.00] ### federal tax increase
years_set = [2016,2017,2018,2019,2020] ## Year of policy implementation

count=0
totalset = 1
for initprice in initprice_set:
	for tax in tax_set:
		for year in years_set:
			scen=(initprice, float(tax), year)          
			print "scenario: ", scen
			os.chdir(dirweb) # change to directory with age effects modifier male and female files
			# Create policy inputs file
			os.system("Rscript Create_taxpolicy_file_WithParams.R %0.2f %0.2f %s" % scen)
				
			# Males
			cmd1="mv inputstax_males_%0.2f_t%0.2f_%s.csv " % scen # move file to policy module inputs folder
			cmd1=cmd1+dirinputs+"policies.csv"
			os.system(cmd1)
			os.chdir(dirinputs) 
			os.system("cp demographics_males.csv demographics.csv")
			os.chdir(dirsim)
			os.system("python policy_shg.py") # run policy module
			cmd2="mv prevalences.csv "+dirresults+"prevalences_males_%0.2f_t%0.2f_%s.csv" % scen
			os.system(cmd2) 
			print "male output file saved ", year
			# Females
			os.chdir(dirweb)
			cmd3="mv inputstax_females_%0.2f_t%0.2f_%s.csv " % scen
			cmd3=cmd3+dirinputs+"policies.csv"
			os.system(cmd3)
			os.chdir(dirinputs)
			os.system("cp demographics_females.csv demographics.csv")
			os.chdir(dirsim)
			os.system("python policy_shg.py")
			cmd4="mv prevalences.csv "+dirresults+"prevalences_females_%0.2f_t%0.2f_%s.csv" % scen
			os.system(cmd4) 
			print "female output file saved ", year
							
		#params = (float(initprice),float(tax),iter1)
		#print "params: ", params[0:1]
		#os.chdir(dirweb)
		#os.system("Rscript generate_tax_policy_website_data.R %0.2f %0.2f %s" % params)
						
		count = count+1
		print "results generated for file ", count, " of ", totalset
