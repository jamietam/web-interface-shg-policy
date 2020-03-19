import os
import csv
import sys
from itertools import product
import multiprocessing as mp
import time

dirweb = '/Users/rafaelmeza/Documents/web-interface-shg-policy'
dirresults = '/Users/rafaelmeza/Documents/airlaws_results/'

scenarioDict = {'0':{'Iwp':[0,1],
                      'Ir':[0,1],
                      'Ib':[0,1],
                      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                      'pacr':[0.00,0.25,0.50,0.75,1.00],
                      'pacb':[0.00,0.25,0.50,0.75,1.00],
                      'years':[2016,2017,2018,2019,2020]
                      }
                }

## CODE CURRENTLY SET UP TO DISTRIBUTE PARAMETER COMBOS TO EACH CORE, NOT EACH SCENARIO TO EACH CORE

def policyrun (Iwp_set,Ir_set,Ib_set,pacwp_set,pacr_set,pacb_set,years_set,directory):
    combos = product(Iwp_set,Ir_set,Ib_set,pacwp_set,pacr_set,pacb_set,years_set)    
    numscenarios = 0
    for scen in list(combos):
#	dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(directory) # Directory contains 'policy_shg.py'
      dirsim ='/Users/rafaelmeza/Documents/shg-policy-module/'# Directory contains 'policy_shg.py'
      dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'

    	# Create policy inputs file
      os.chdir(dirweb)
      os.system("Rscript create_airlaws_params_file.R %s %s %s %0.2f %0.2f %0.2f %s" % scen)

      ## Males Run scenario
      cmd1="mv inputsairlaws_males_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv " % scen # move file to policy module inputs folder
      cmd1=cmd1+dirinputs+"policies.csv"
      os.system(cmd1)
      os.chdir(dirsim)
      
      runitM = "python policy_popmodel.py >> ../logM{0}.txt 2>> ../errorM{0}.txt".format(directory) ### NAME THESE AS THE SCENARIO
      os.system(runitM) # run policy module
      
      cmd2="mv prevalences_males.csv "+dirresults+"prevalences_males_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv" % scen
      os.system(cmd2)

    	## Females Run Scenario
      os.chdir(dirweb)
      cmd3="mv inputsairlaws_females_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv " % scen
      cmd3=cmd3+dirinputs+"policies.csv"
      os.system(cmd3)
      
      os.chdir(dirsim)

      runitF = "python policy_popmodel.py >> ../logM{0}.txt 2>> ../errorM{0}.txt".format(directory) ### NAME THESE AS THE SCENARIO
      os.system(runitF) # run policy module
      
      cmd4="mv prevalences_females.csv "+dirresults+"prevalences_females_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv" % scen
      os.system(cmd4)
      
      numscenarios = numscenarios+1
    print ("directory " + str(directory)+" = " + str(numscenarios)+ " scenarios")
    print >>sys.stderr, "Done with all combos={}".format(directory)
    print scen

# Run scenarios in parallel and serially within each thread

if __name__ == '__main__':
    # cpus = mp.cpu_count()
    pool = mp.Pool(processes=1)
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
        pool.apply_async(policyrun, args=(Iwp_set,Ir_set,Ib_set,pacwp_set,pacr_set,pacb_set,years_set,directory))

    pool.close() #closes the pool and prevents you from submitting any more jobs
    pool.join() # waits for all the jobs to finish before moving onto the next line of code

## NEXT STEP: Generate TCP tool files at US-level with tcptool_airlaws_data.R
