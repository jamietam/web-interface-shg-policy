import os
import csv
import sys

# Run scenarios in parallel and serially within each thread
iter1 = str(4)
print "iteration: ", iter1

dirsim='/home/jamietam/shg-policy-module_parallel_'+iter1+'/' # Directory contains 'policy_shg.py'
dirinputs=dirsim+'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
dirscen = '/home/jamietam/scenarios_parallel_'+iter1+'/'
dirweb = '/home/jamietam/web-interface-shg-policy/'## Directory contains 'Age_effects_male_cleanair_021815.csv', 'Age_effects_female_cleanair_021$
dirresults = dirweb+'cleanairresults/'

Iwp_set = [1] ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir_set = [1] ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib_set = [1] ### indicator of bars policy to be implemented 1-yes, 0-no
pacwp_set = [0.00] ### percentage already covered by workplace clean air laws
pacr_set = [1.00] ### percentage already covered by restaurants clean air laws
pacb_set = [0.00,0.25,0.50,0.75,1.00] ### percentage already covered by bars clean air laws
years_set = [2016,2017,2018,2019,2020] ## Year of policy implementation

count=0
totalset = 5
for Iwp in Iwp_set:
	for Ir in Ir_set:
		for Ib in Ib_set:
			for pacwp in pacwp_set:
				for pacr in pacr_set:
					for pacb in pacb_set:
						for year in years_set:
							scen=(Iwp, Ir, Ib, float(pacwp), float(pacr), float(pacb), year)          
							print "scenario: ", scen
							os.chdir(dirweb) # change to directory with age effects modifier male and female files
							# Create policy inputs file
							os.system("Rscript Create_cleanairpolicy_file_WithParams.R %s %s %s %0.2f %0.2f %0.2f %s" % scen)
							
							# Males
							cmd1="mv inputscleanair_males_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv " % scen # move file to policy module inputs folder
							cmd1=cmd1+dirinputs+"policies.csv"
							os.system(cmd1)
							os.chdir(dirinputs) 
							os.system("cp demographics_males.csv demographics.csv")
							os.chdir(dirsim)
							os.system("python policy_shg.py") # run policy module
							cmd2="mv prevalences.csv "+dirscen+"prevalences_males_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv" % scen
							os.system(cmd2) 
							print "male output file saved ", year
							# Females
							os.chdir(dirweb)
							cmd3="mv inputscleanair_females_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv " % scen
							cmd3=cmd3+dirinputs+"policies.csv"
							os.system(cmd3)
							os.chdir(dirinputs)
							os.system("cp demographics_females.csv demographics.csv")
							os.chdir(dirsim)
							os.system("python policy_shg.py")
							cmd4="mv prevalences.csv "+dirscen+"prevalences_females_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv" % scen
							os.system(cmd4) 
							print "female output file saved ", year
							
						params = (Iwp,Ir,Ib,float(pacwp),float(pacr),float(pacb),iter1)
						print "params: ", params[0:6]
						os.chdir(dirweb)
						os.system("Rscript generate_shg_policy_website_data.R %s %s %s %0.2f %0.2f %0.2f %s" % params)
						
						count = count+1
						print "results generated for file ", count, " of ", totalset
