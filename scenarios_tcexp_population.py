# -*- coding: utf-8 -*-

import os
import csv
import sys
from itertools import product
import multiprocessing as mp
import time

#dirweb = '/Users/rafaelmeza/Documents/web-interface-shg-policy'
#dirresults = '/Users/rafaelmeza/Documents/tcexp_results/'

dirs=open('Directories', 'r').readlines()
dirweb=dirs[1].strip().split('=')[1]  # web interface directory
dirresults = dirs[5].strip().split('=')[1]  # tcexp results directory
dirtcp=dirs[0].strip().split('=')[1]  ## tcp tool directory

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
      dirsim =dirtcp# Directory contains 'policy_shg.py'
      #dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(directory) # Directory contains 'policy_shg.py'
      dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
    	# Create policy inputs file
      os.chdir(dirweb)
      os.system("Rscript create_tcexp_params_file.R %0.2f %0.2f %s" % scen)
      
      ##  Run scenario - both sexes at once since effects don't differ
      cmd1="mv inputstcexp_males_initexp%0.2f_policyexp%0.2f_%s.csv " % scen # move file to policy module inputs folder
      cmd1=cmd1+dirinputs+"policies.csv"
      os.system(cmd1)
      os.chdir(dirsim)
      
      runitMF = "python policy_popmodel.py >> ../logM{0}.txt 2>> ../errorM{0}.txt".format(directory) ### NAME THESE AS THE SCENARIO
      os.system(runitMF) # run policy module
      
      cmd2="mv prevalences_males.csv "+dirresults+"prevalences_males_initexp%0.2f_policyexp%0.2f_%s.csv" % scen
      os.system(cmd2)
      cmd3="mv prevalences_females.csv "+dirresults+"prevalences_females_initexp%0.2f_policyexp%0.2f_%s.csv" % scen
      os.system(cmd3)
      numscenarios = numscenarios+1

    print ("directory " + str(directory)+" = " + str(numscenarios)+ " scenarios")
    print >>sys.stderr, "Done with all combos={}".format(directory)
    print scen

# Run scenarios in parallel and serially within each thread

if __name__ == '__main__':
    # cpus = mp.cpu_count()
    pool = mp.Pool(processes=1)
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

