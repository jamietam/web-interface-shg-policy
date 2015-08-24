import os
import csv
import sys

# Run scenarios serially

dirsim='/home/jamietam/shg-policy-module/' # Directory contains 'policy_shg.py'
dirinputs=dirsim+'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
dirscen = '/home/jamietam/scenarios/' 
dirweb = '/home/jamietam/web-interface-shg-policy/'## Directory contains 'Age_effects_male_cleanair_021815.csv', 'Age_effects_female_cleanair_021$
dirresults = dirscen+'/cleanairresults/'

Iwp_set = [1] ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir_set = [1] ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib_set = [1] ### indicator of bars policy to be implemented 1-yes, 0-no
pacwp_set = [0.00,0.25,0.50,0.75,1.00] ### percentage already covered by workplace clean air laws
pacr_set = [0.00,0.25,0.50,0.75,1.00] ### percentage already covered by restaurants clean air laws
pacb_set = [1.00] ### percentage already covered by bars clean air laws
years_set = [2015,2016,2018,2020] ## Year of policy implementation

count=0
totalset = 25
for Iwp in Iwp_set:
	for Ir in Ir_set:
		for Ib in Ib_set:
			for pacwp in pacwp_set:
				for pacr in pacr_set:
					for pacb in pacb_set:
						for year in years_set:
							scen=(Iwp, Ir, Ib, pacwp, pacr, pacb, year)          
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
							
						params = (Iwp,Ir,Ib,float(pacwp),float(pacr),float(pacb))
						print "params: ", params
						os.chdir(dirweb)
						os.system("Rscript serial_generate_shg_policy_website_data.R %s %s %s %0.2f %0.2f %0.2f" % params)
						count = count+1
						print "results generated for file ", count, " of ", totalset
