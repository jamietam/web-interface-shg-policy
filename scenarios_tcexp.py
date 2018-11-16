# -*- coding: utf-8 -*-

import os
import csv
import sys
from itertools import product
import multiprocessing as mp
import time

cohortsize = 50
lastcohort = 2060
dirweb = '/home/jamietam/web-interface-shg-policy/'
dirresults = '/home/jamietam/tcexp_results/'

scenarioDict = {'0':{'initexp':[0.00],
                     'policyexp':[0.00,0.10,0.20,0.30],
                     'years':[2016,2017,2018,2019,2020]
                      },
               '1':{'initexp':[0.00],
                    'policyexp':[0.40,0.50,0.60,0.70],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '2':{'initexp':[0.00],
                    'policyexp':[0.80,0.90,1.00],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '3':{'initexp':[0.10],
                    'policyexp':[0.20,0.30,0.40,0.50],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '4':{'initexp':[0.10],
                    'policyexp':[0.60,0.70,0.80],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '5':{'initexp':[0.10],
                    'policyexp':[0.90,1.00],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '6':{'initexp':[0.20],
                    'policyexp':[0.30,0.40,0.50,0.60],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '7':{'initexp':[0.20],
                    'policyexp':[0.70,0.80,0.90,1.00],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '8':{'initexp':[0.30],
                    'policyexp':[0.40,0.50,0.60],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '9':{'initexp':[0.30],
                    'policyexp':[0.70,0.80,0.90,1.00],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '10':{'initexp':[0.40],
                    'policyexp':[0.50,0.60,0.70],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '11':{'initexp':[0.40],
                    'policyexp':[0.80,0.90,1.00],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '12':{'initexp':[0.50],
                    'policyexp':[0.60,0.70,0.80],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '13':{'initexp':[0.50],
                    'policyexp':[0.90,1.00],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '14':{'initexp':[0.60],
                    'policyexp':[0.70,0.80,0.90,1.00],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '15':{'initexp':[0.70],
                    'policyexp':[0.80,0.90,1.00],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '16':{'initexp':[0.80],
                    'policyexp':[0.90,1.00],
                    'years':[2016,2017,2018,2019,2020]
                      },
               '17':{'initexp':[0.90],
                    'policyexp':[1.00],
                    'years':[2016,2017,2018,2019,2020]
                      }
                }

## CODE CURRENTLY SET UP TO DISTRIBUTE PARAMETER COMBOS TO EACH CORE, NOT EACH SCENARIO TO EACH CORE

def policyrun (initexp_set,policyexp_set,years_set,directory):
    combos = product(initexp_set,policyexp_set,years_set)
    numscenarios = 0
    for scen in list(combos):
	dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(directory) # Directory contains 'policy_shg.py'
	dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
    	# Create policy inputs file
    	os.chdir(dirweb)
        os.system("Rscript create_tcexp_params_file.R %0.2f %0.2f %s" % scen)

    	## Males
    	cmd1="mv inputstcexp_males_initexp%0.2f_policyexp%0.2f_%s.csv " % scen # move file to policy module inputs folder
    	cmd1=cmd1+dirinputs+"policies.csv"
        os.system(cmd1)
        demoM ="cp "+dirweb+"demographics/demographics_males_"+str(cohortsize)+"_" +str(lastcohort)+".csv "+dirinputs+"demographics.csv"
        os.system(demoM)
        os.chdir(dirsim)

    	runitM = "python policy_shg.py >> ../logM{0}.txt 2>> ../errorM{0}.txt".format(directory) ### NAME THESE AS THE SCENARIO
    	os.system(runitM) # run policy module

    	cmd2="mv prevalences.csv "+dirresults+"prevalences_males_initexp%0.2f_policyexp%0.2f_%s.csv" % scen
    	os.system(cmd2)

    	## Females
    	os.chdir(dirweb)
    	cmd3="mv inputstcexp_females_initexp%0.2f_policyexp%0.2f_%s.csv " % scen
    	cmd3=cmd3+dirinputs+"policies.csv"
        os.system(cmd3)
        demoF ="cp "+dirweb+"demographics/demographics_females_"+str(cohortsize)+"_" +str(lastcohort)+".csv "+dirinputs+"demographics.csv"
        os.system(demoF)
        os.chdir(dirsim)

    	runitF = "python policy_shg.py >> ../logF{0}.txt 2>> ../errorF{0}.txt".format(directory)
    	os.system(runitF) # run policy module

	cmd4="mv prevalences.csv "+dirresults+"prevalences_females_initexp%0.2f_policyexp%0.2f_%s.csv" % scen
    	os.system(cmd4)
	numscenarios = numscenarios+1
    print ("directory " + str(directory)+" = " + str(numscenarios)+ " scenarios")
    print >>sys.stderr, "Done with all combos={}".format(directory)
    print scen

# Run scenarios in parallel and serially within each thread

if __name__ == '__main__':
    # cpus = mp.cpu_count()
    pool = mp.Pool(processes=18)
    for key, scenario in scenarioDict.items():
## NEXT STEP: Generate TCP tool files at US-level with tcptool_airlaws_data.R
        directory = key
        print("ITERATION: "+ directory)

        initexp_set = scenario['initexp']
        policyexp_set = scenario['policyexp']
        years_set = scenario['years'] ## Year of policy implementation
        pool.apply_async(policyrun, args=(initexp_set,policyexp_set,years_set,directory))

    pool.close() #closes the pool and prevents you from submitting any more jobs
    pool.join() # waits for all the jobs to finish before moving onto the next line of code

## NEXT STEP: Generate TCP tool files at US-level with tcptool_tcexp_data.R

