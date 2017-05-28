import os
import csv
import sys

#dirprevs='/home/jamietam/mla_results/prevs/' # Directory contains prevalence files
dirweb = '/home/jamietam/web-interface-shg-policy/'## Directory contains 'Age_effects_male_cleanair_021815.csv', 'Age_effects_female_cleanair_021$
dirresults = '/home/jamietam/cleanair_results/'

Iwp_set = [1] ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir_set = [1] ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib_set = [1] ### indicator of bars policy to be implemented 1-yes, 0-no
pacwp_set = [1.00] ### percentage already covered by workplace clean air laws
pacr_set = [0.00,0.25,0.50,0.75,1.00] ### percentage already covered by restaurants clean air laws
pacb_set = [0.50,0.75,1.00] ### percentage already covered by bars clean air laws

os.chdir(dirweb) # change to main directory

count=0
totalset = 1
for Iwp in Iwp_set:
        for Ir in Ir_set:
                for Ib in Ib_set:
                        for pacwp in pacwp_set:
                                for pacr in pacr_set:
                                        for pacb in pacb_set:
        					scen=(Iwp, Ir, Ib, float(pacwp), float(pacr), float(pacb))
						print "scenario: ", scen
						os.system("Rscript generate_cleanair_policy_website_data.R %s %s %s %0.2f %0.2f %0.2f" % scen)
					        count = count+1
					        print "results generated for file ", count, " of ", totalset
						cmd5 = "mv deaths* results* lyg* "+dirresults
						os.system(cmd5) 
						print "files moved to ", dirresults
