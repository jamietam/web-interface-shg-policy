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
dirresults = '/home/jamietam/tcexp_results/'

initexp_set = [0.00] ### initial funding
finalexp_set = [0.50,0.40,0.30,0.20,0.10] ### final funding
years_set = [2016,2017,2018,2019,2020] ## Year of policy implementation

count=0
totalset = 1
for initexp in initexp_set:
	for finalexp in finalexp_set:
		for year in years_set:
			scen=(float(initexp), float(finalexp), year)          
			print "scenario: ", scen
			os.chdir(dirweb) # 
			# Create policy inputs file
			os.system("Rscript Create_tcexppolicy_file_WithParams.R %0.2f %0.2f %s" % scen)
				
			# Males
			cmd1="mv inputstcexp_males_initexp%0.2f_policyexp%0.2f_%s.csv " % scen # move file to policy module inputs folder
			cmd1=cmd1+dirinputs+"policies.csv"
			os.system(cmd1)
			os.chdir(dirinputs) 
			os.system("cp demographics_males.csv demographics.csv")
			os.chdir(dirsim)
			os.system("python policy_shg.py") # run policy module
			cmd2="mv prevalences.csv "+dirresults+"prevalences_males_initexp%0.2f_policyexp%0.2f_%s.csv" % scen
			os.system(cmd2) 
			print "male output file saved ", year
			# Females
			os.chdir(dirweb)
			cmd3="mv inputstcexp_females_initexp%0.2f_policyexp%0.2f_%s.csv " % scen
			cmd3=cmd3+dirinputs+"policies.csv"
			os.system(cmd3)
			os.chdir(dirinputs)
			os.system("cp demographics_females.csv demographics.csv")
			os.chdir(dirsim)
			os.system("python policy_shg.py")
			cmd4="mv prevalences.csv "+dirresults+"prevalences_females_initexp%0.2f_policyexp%0.2f_%s.csv" % scen
			os.system(cmd4) 
			print "female output file saved ", year
							
		#params = (float(initexp),float(finalexp),iter1)
		#print "params: ", params[0:1]
		#os.chdir(dirweb)
		#os.system("Rscript generate_tax_policy_website_data.R %0.2f %0.2f %s" % params)
						
		count = count+1
		print "results generated for file ", count, " of ", totalset
