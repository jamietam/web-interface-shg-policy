import os
import csv

dirsim='/home/jamietam/shg-policy-module' # Directory contains 'policy_shg.py'
dirinputs='/home/jamietam/shg-policy-module/inputs' # Directory contains 'policies.csv' and 'demographics.csv'
dirscen = '/home/jamietam/scenarios' ## Directory contains 'Age_effects_male_cleanair_021815.csv', 'Age_effects_female_cleanair_021815.csv','Create_cleanairpolicy_file_WithParams.R ','generate_shg_policy_website_data.R', 'censuspop2010to2060.csv'
dirresults = '/home/jamietam/scenarios/cleanairresults'

#Iwp_set = [0, 1] ### indicator of workplace policy to be implemented 1-yes, 0-no
#Ir_set = [0, 1] ### indicator of restaurants policy to be implemented 1-yes, 0-no
#Ib_set = [0, 1] ### indicator of bars policy to be implemented 1-yes, 0-no
#pacwp_set = [0.0, 0.25, 0.50, 0.75, 1.0] ### percentage already covered by workplace clean air laws
#pacr_set = [0.0, 0.25, 0.50, 0.75, 1.0] ### percentage already covered by restaurants clean air laws
#pacb_set = [0.0, 0.25, 0.50, 0.75, 1.0] ### percentage already covered by bars clean air laws
#years_set = [2015, 2016, 2018, 2020] ## Year of policy implementation

#Test run with one parameter in each set
Iwp_set = [1] ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir_set = [0] ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib_set = [0] ### indicator of bars policy to be implemented 1-yes, 0-no
pacwp_set = [0] ### percentage already covered by workplace clean air laws
pacr_set = [0] ### percentage already covered by restaurants clean air laws
pacb_set = [0] ### percentage already covered by bars clean air laws
years_set = [2015,2016,2018,2020] ## Year of policy implementation

count=0

for Iwp in Iwp_set:
	for Ir in Ir_set:
		for Ib in Ib_set:
			for pacwp in pacwp_set:
				for pacr in pacr_set:
					for pacb in pacb_set:
						params = (Iwp,Ir,Ib,pacwp,pacr,pacb)
						for year in years_set:
							scen=(Iwp, Ir, Ib, pacwp, pacr, pacb, year)          
							print "scenario: ", scen
							os.chdir(dirscen) # change to directory with age effects modifier male and female files
							# Create policy inputs file
							# os.system("Rscript Create_cleanairpolicy_file_WithParams.R %s %s %s %s %s %s %s" % scen)
							
							# Males
							# os.system("mv inputscleanair_males_w%s_r%s_b%s_w%s_r%s_b%s_%s.csv /home/jamietam/shg-policy-module/inputs/policies.csv" % scen) # move file to policy module inputs folder
							# os.chdir(dirinputs) 
							# os.system("cp demographics_males.csv demographics.csv")
							# os.chdir(dirsim)
							# os.system("python policy_shg.py") # run policy module
							#os.system("mv prevalences.csv /home/jamietam/scenarios/prevalences_males_%s.csv" % year) 
							print "male output file saved ", year
							# Females
							# os.chdir(dirscen)
							os.system("mv inputscleanair_females_w%s_r%s_b%s_w%s_r%s_b%s_%s.csv /home/jamietam/shg-policy-module/inputs/policies.csv" % scen)
							os.chdir(dirinputs)
							os.system("cp demographics_females.csv demographics.csv")
							os.chdir(dirsim)
							os.system("python policy_shg.py")
							os.system("mv prevalences.csv /home/jamietam/scenarios/prevalences_females_%s.csv" % year) 
							print "female output file saved ", year
							
						os.chdir(dirscen)
						os.system("Rscript generate_shg_policy_website_data.R")
						os.system("mv results_w%s_r%s_b%s_w%s_r%s_b%s.csv home/jamietam/scenarios/cleanairresults/results_w%s_r%s_b%s_w%s_r%s_b%s.csv" % params)
						os.system("mv deaths_w%s_r%s_b%s_w%s_r%s_b%s.csv home/jamietam/scenarios/cleanairresults/results_w%s_r%s_b%s_w%s_r%s_b%s.csv" % params)
						count = count+1
						print "results generated for file ", count, " of 2"