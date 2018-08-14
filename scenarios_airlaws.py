# -*- coding: utf-8 -*-

import os
import csv
import sys
from itertools import product
import multiprocessing as mp
import time

dirweb = '/home/jamietam/web-interface-shg-policy/'# Directory contains age effects files
dirresults = '/home/jamietam/airlaws_results/'

scenarioDict = {'0':{'Iwp':[0],
                      'Ir':[0],
                      'Ib':[0],
                      'pacwp':[0.0],
                      'pacb':[0.0],
                      'pacr':[0.0],
                      'years':range(2016,2021)
                      },
               '1':{'Iwp':[1],
                      'Ir':[0],
                      'Ib':[0],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.00],
                      'pacr':[0.00],
                      'years':range(2016,2021)
                      },
               '2':{'Iwp':[0],
                      'Ir':[1],
                      'Ib':[0],
                     'pacwp':[0.00],
                      'pacb':[0.00,0.25,0.50,0.75,1.00],
                      'pacr':[0.00],
                      'years':range(2016,2021)
                      },
               '3':{'Iwp':[0],
                      'Ir':[0],
                      'Ib':[1],
                      'pacwp':[0.00],
                      'pacb':[0.00],
                      'pacr':[0.00,0.25,0.50,0.75,1.00],
                      'years':range(2016,2021)
                      } ,
               '4':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[0],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.00,0.25],
                      'pacr':[0.00],
                      'years':range(2016,2021)
                      },
               '5':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[0],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.50, 0.75,1.00],
                      'pacr':[0.00],
                      'years':range(2016,2021)
                      },

               '6':{'Iwp':[1],
                      'Ir':[0],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.00],
                      'pacr':[0.00,0.25],
                      'years':range(2016,2021)
                      },
               '7':{'Iwp':[1],
                      'Ir':[0],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.00],
                      'pacr':[0.50,0.75,1.00],
                      'years':range(2016,2021)
                      },
               '8':{'Iwp':[0],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00],
                      'pacb':[0.00,0.25,0.50, 0.75,1.00],
                      'pacr':[0.00,0.25],
                      'years':range(2016,2021)
                      },
               '9':{'Iwp':[0],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00],
                      'pacb':[0.00,0.25,0.50, 0.75,1.00],
                      'pacr':[0.50,0.75,1.00],
                      'years':range(2016,2021)
                      },
               '10':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.00,0.25],
                      'pacr':[0.00],
                      'years':range(2016,2021)
                      },
               '11':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.50, 0.75,1.00],
                      'pacr':[0.00],
                      'years':range(2016,2021)
                      },
                '12':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.00,0.25],
                      'pacr':[0.25],
                      'years':range(2016,2021)
                      },
               '13':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.50, 0.75,1.00],
                      'pacr':[0.25],
                      'years':range(2016,2021)
                      },
                '14':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.00,0.25],
                      'pacr':[0.50],
                      'years':range(2016,2021)
                      },
               '15':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.50, 0.75,1.00],
                      'pacr':[0.50],
                      'years':range(2016,2021)
                      },
                '16':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.00,0.25],
                      'pacr':[0.75],
                      'years':range(2016,2021)
                      },
               '17':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.50, 0.75,1.00],
                      'pacr':[0.75],
                      'years':range(2016,2021)
                      },
                '18':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.00,0.25],
                      'pacr':[1.00],
                      'years':range(2016,2021)
                      },
                '19':{'Iwp':[1],
                      'Ir':[1],
                      'Ib':[1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.50,0.75,1.00],
                      'pacr':[1.00],
                      'years':range(2016,2021)
                      }

                }

## CODE CURRENTLY SET UP TO DISTRIBUTE PARAMETER COMBOS TO EACH CORE, NOT EACH SCENARIO TO EACH CORE

def policyrun (Iwp_set,Ir_set,Ib_set,pacwp_set,pacr_set,pacb_set,years_set,directory):
    combos = product(Iwp_set,Ir_set,Ib_set,pacwp_set,pacr_set,pacb_set,years_set)    
    numscenarios = 0 
    for scen in list(combos):
	dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(directory) # Directory contains 'policy_shg.py'
	dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
    	# Create policy inputs file
    	os.chdir(dirweb)
        os.system("Rscript create_airlaws_params_file.R %s %s %s %0.2f %0.2f %0.2f %s" % scen)

    	## Males
    	cmd1="mv inputsairlaws_males_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv " % scen # move file to policy module inputs folder
    	cmd1=cmd1+dirinputs+"policies.csv"
    	os.system(cmd1)
    	os.chdir(dirinputs)
    	os.system("cp demographics_males_200000.csv demographics.csv")
    	os.chdir(dirsim)

    	runitM = "python policy_shg.py >> ../logM{0}.txt 2>> ../errorM{0}.txt".format(directory) ### NAME THESE AS THE SCENARIO
    	os.system(runitM) # run policy module

    	cmd2="mv prevalences.csv "+dirresults+"prevalences_males_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv" % scen
    	os.system(cmd2)

    	## Females
    	os.chdir(dirweb)
    	cmd3="mv inputsairlaws_females_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv " % scen
    	cmd3=cmd3+dirinputs+"policies.csv"
    	os.system(cmd3)
    	os.chdir(dirinputs)
    	os.system("cp demographics_females_200000.csv demographics.csv")
    	os.chdir(dirsim)

    	runitF = "python policy_shg.py >> ../logF{0}.txt 2>> ../errorF{0}.txt".format(directory)
    	os.system(runitF) # run policy module
	cmd4="mv prevalences.csv "+dirresults+"prevalences_females_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv" % scen
    	os.system(cmd4)
	numscenarios = numscenarios+1
    print ("directory " + str(directory)+" = " + str(numscenarios)+ " scenarios")
    print >>sys.stderr, "Done with all combos={}".format(directory)
    print scen

# Run scenarios in parallel and serially within each thread

if __name__ == '__main__':
    # cpus = mp.cpu_count()
    pool = mp.Pool(processes=20)
    for key, scenario in scenarioDict.items():
        directory = key
        print("ITERATION: "+ directory)

        Iwp_set = scenario['Iwp'] ### indicator of workplace policy to be implemented 1-yes, 0-no
        Ir_set = scenario['Ir'] ### indicator of restaurants policy to be implemented 1-yes, 0-no
        Ib_set = scenario['Ib'] ### indicator of bars policy to be implemented 1-yes, 0-no
        pacwp_set = scenario['pacwp'] ### percentage already covered by workplace clean air laws
        pacr_set = scenario['pacr'] ### percentage already covered by restaurants clean air laws
        pacb_set = scenario['pacb'] ### percentage already covered by bars clean air laws
        years_set = scenario['years'] ## Year of policy implementation
#        policyrun(Iwp_set,Ir_set,Ib_set,pacwp_set,pacr_set,pacb_set,years_set,directory)
        pool.apply_async(policyrun, args=(Iwp_set,Ir_set,Ib_set,pacwp_set,pacr_set,pacb_set,years_set,directory))

    pool.close() #closes the pool and prevents you from submitting any more jobs
    pool.join() # waits for all the jobs to finish before moving onto the next line of code
