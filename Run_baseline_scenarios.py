import os
import csv
import sys

dirsim='/home/jamietam/shg-policy-module_parallel/' # Directory contains 'policy_shg.py'
dirinputs=dirsim+'/inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
dirscen = '/home/jamietam/scenarios_parallel/' ## Directory contains 'Age_effects_male_cleanair_021815.csv', 'Age_effects_female_cleanair_021815.csv','Create_cleanairpolicy_file_WithParams.R ','generate_shg_policy_website_data.R', 'censuspop2010to2060.csv'
dirresults = dirscen+'/cleanairresults/'

#Iwp_set = [0, 1] ### indicator of workplace policy to be implemented 1-yes, 0-no
#Ir_set = [0, 1] ### indicator of restaurants policy to be implemented 1-yes, 0-no
#Ib_set = [0, 1] ### indicator of bars policy to be implemented 1-yes, 0-no
#pacwp_set = [0.0, 0.25, 0.50, 0.75, 1.0] ### percentage already covered by workplace clean air laws
#pacr_set = [0.0, 0.25, 0.50, 0.75, 1.0] ### percentage already covered by restaurants clean air laws
#pacb_set = [0.0, 0.25, 0.50, 0.75, 1.0] ### percentage already covered by bars clean air laws
#years_set = [2015, 2016, 2018, 2020] ## Year of policy implementation

#Test run with one parameter in each set
Iwp_set = [0] ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir_set = [0] ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib_set = [0] ### indicator of bars policy to be implemented 1-yes, 0-no
pacwp_set = [0] ### percentage already covered by workplace clean air laws
pacr_set = [0] ### percentage already covered by restaurants clean air laws
pacb_set = [0] ### percentage already covered by bars clean air laws
years_set = [2015] ## Year of policy implementation

count=0
totalset = 1
for Iwp in Iwp_set:
	for Ir in Ir_set:
		for Ib in Ib_set:
			for pacwp in pacwp_set:
				for pacr in pacr_set:
					for pacb in pacb_set:
						for year in years_set:
							scen=(Iwp, Ir, Ib, pacwp, pacr, pacb, year)          
							print "scenario: ", scen
							os.chdir(dirscen) # change to directory with age effects modifier male and female files
							# Create policy inputs file
							os.system("Rscript Create_cleanairpolicy_file_WithParams.R %s %s %s %s %s %s %s" % scen)
							
							# Males
							cmd="mv inputscleanair_males_w%s_r%s_b%s_w%s_r%s_b%s_%s.csv /home/jamietam/shg-policy-module/inputs/policies.csv" % scen
							os.chdir(dirinputs) 
							os.system("cp demographics_males.csv demographics.csv")
							os.chdir(dirsim)
							os.system("python policy_shg.py") # run policy module
							cmd2 = "mv prevalences.csv "+dirscen+"baseline_prevalences_males.csv"
							os.system(cmd2) 
							 
							print "male baseline output file saved ", year

							# Females
							os.chdir(dirscen)
							os.system("mv inputscleanair_females_w%s_r%s_b%s_w%s_r%s_b%s_%s.csv /home/jamietam/shg-policy-module/inputs/policies.csv" % scen)
							os.chdir(dirinputs)
							os.system("cp demographics_females.csv demographics.csv")
							os.chdir(dirsim)
							os.system("python policy_shg.py")
							cmd3 = "mv prevalences.csv "+dirscen+"baseline_prevalences_females.csv"
							os.system(cmd3)

							print "female baseline output file saved ", year
							
						count = count+1
						print "baseline results generated."