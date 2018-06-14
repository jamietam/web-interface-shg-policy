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
                      'years':range(2016,2021),
                      }#,
                #'1':{'Iwp':[1],
                #      'Ir':[0],
                #      'Ib':[0],
                #      'pacwp':[0.00,0.25,0.50,0.75,1.00],
                #      'pacb':[0.0],
                #      'pacr':[0.0],
                #      'years':range(2016,2021)
                #      }#,
                #'2':{'Iwp':[0],
                #      'Ir':[1],
                #      'Ib':[0],
                #      'pacwp':[0.0],
                #      'pacr':[0.00,0.25,0.50,0.75,1.00],
                #      'pacb':[0.0],
                #      'years':range(2016,2021)
                #      }
                }

def policyrun (scen,whichiter):
    dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(whichiter) # Directory contains 'policy_shg.py'
    dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'

    #print("SCENARIO:", scen)
    #print(dirweb) # change to directory with age effects modifier male and female files
    # Create policy inputs file
    os.system("Rscript create_airlaws_params_file.R %s %s %s %0.2f %0.2f %0.2f %s" % scen)
    
    ## Males
    cmd1="mv inputsairlaws_males_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv " % scen # move file to policy module inputs folder
    cmd1=cmd1+dirinputs+"policies.csv"
    os.system(cmd1)
    os.chdir(dirinputs)
    os.system("cp demographics_males_50.csv demographics.csv")
    os.chdir(dirsim)
    os.system("python policy_shg.py") # run policy module
    cmd2="mv prevalences.csv "+dirresults+"prevalences_males_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv" % scen
    os.system(cmd2)
    #print("male output file saved ", scen[-1])
    ## Females
    os.chdir(dirweb)
    cmd3="mv inputsairlaws_females_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv " % scen
    cmd3=cmd3+dirinputs+"policies.csv"
    os.system(cmd3)
    os.chdir(dirinputs)
    os.system("cp demographics_females_50.csv demographics.csv")
    os.chdir(dirsim)
    os.system("python policy_shg.py")
    cmd4="mv prevalences.csv "+dirresults+"prevalences_females_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv" % scen
    os.system(cmd4)
    #print("female output file saved ", scen[-1])
    
    #print("params: ", scen)
    return scen

 
# Run scenarios in parallel and serially within each thread

if __name__ == '__main__':
    # cpus = mp.cpu_count()
    pool = mp.Pool(processes=4)

    numscenarios = 0 
    for key, scenario in scenarioDict.items():
        iter1 = key
        print("ITERATION: "+ iter1)
        
        #dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(iter1) # Directory contains 'policy_shg.py'
        #dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
        
        Iwp_set = scenario['Iwp'] ### indicator of workplace policy to be implemented 1-yes, 0-no
        Ir_set = scenario['Ir'] ### indicator of restaurants policy to be implemented 1-yes, 0-no
        Ib_set = scenario['Ib'] ### indicator of bars policy to be implemented 1-yes, 0-no
        pacwp_set = scenario['pacwp'] ### percentage already covered by workplace clean air laws
        pacr_set = scenario['pacr'] ### percentage already covered by restaurants clean air laws
        pacb_set = scenario['pacb'] ### percentage already covered by bars clean air laws
        years_set = scenario['years'] ## Year of policy implementation
        
        combos = product(Iwp_set,Ir_set,Ib_set,pacwp_set,pacr_set,pacb_set,years_set)    
        
        for scen in list(combos):
            ### Your future multiprocessing parallel function would look as follows:
            # pool.apply_async(function_to_parallelize, args=(Iwp,Ir,Ib,pacwp,pacr,pacb,year) )
            pool.apply_async(policyrun, (scen,iter1,))
            pool.close()
            pool.join()
            print (str(scen))
            #print (result.get(timeout=1))
           #policyrun(scen)
            
        numscenarios = numscenarios+1
    print ("total scenarios = " + str(numscenarios))
    
        