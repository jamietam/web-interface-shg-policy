import os
import csv
import sys

iter1=sys.argv[1]

print "iteration: ", iter1

#dirsim='/home/jamietam/shg-policy-module_parallel/'
#dirinputs=dirsim+'inputs/'
#dirscen= '/home/jamietam/scenarios_parallel/'

dirsim='/home/jamietam/shg-policy-module_parallel_'+iter1+'/' # Directory contains 'policy_shg.py'
dirinputs=dirsim+'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
dirscen = '/home/jamietam/scenarios_parallel_'+iter1+'/' 
dirweb = '/home/jamietam/web-interface-shg-policy/' ## Directory contains 'Age_effects_male_cleanair_021815.csv', 'Age_effects_female_cleanair_021815.csv','Create_cleanairpolicy_file_WithParams.R ','generate_shg_policy_website_data.R', 'censuspop2010to2060.csv'

Iwp_set = [sys.argv[2]] ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir_set = [sys.argv[3]] ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib_set = [sys.argv[4]] ### indicator of bars policy to be implemented 1-yes, 0-no
pacwp_set = [sys.argv[5]] ### percentage already covered by workplace clean air laws
pacr_set = [sys.argv[6]] ### percentage already covered by restaurants clean air laws
pacb_set = [sys.argv[7]] ### percentage already covered by bars clean air laws
years_set = [2015,2016,2018,2020] ## Year of policy implementation

count=0
totalset = 1
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
							cmd0 = "Rscript Create_cleanairpolicy_file_WithParams.R %s  %s %s %0.2f %0.2f %0.2f %s" % scen
							os.system(cmd0)
							print(os.getcwd() + "\n")

							# Males
							cmd="mv inputscleanair_males_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv " % scen
							cmd=cmd+dirinputs+"policies.csv"
							os.system(cmd) # move file to policy module inputs folder
							os.chdir(dirinputs) 
							os.system("cp demographics_males.csv demographics.csv")
							os.chdir(dirsim)
							os.system("python policy_shg.py") # run policy module	 
							cmd2 = "mv prevalences.csv "+dirscen+"prevalences_males_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv" % scen
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
							cmd4 = "mv prevalences.csv "+dirscen+"prevalences_females_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv" % scen
							os.system(cmd4)
							print "female output file saved ", year
							
						params = (Iwp,Ir,Ib,float(pacwp),float(pacr),float(pacb),iter1)
						print "params: ", params[0:6]
						#params=(Iwp,Ir,Ib,pacwp,pacr,pacb)
						os.chdir(dirweb)
						os.system("Rscript ./generate_shg_policy_website_data.R %s %s %s %0.2f %0.2f %0.2f %s" % params)
										
						count = count+1
						print "results generated for file ", count, " of ", totalset
