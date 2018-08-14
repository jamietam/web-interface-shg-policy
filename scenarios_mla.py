import os
import csv
import sys
from itertools import product
import multiprocessing as mp
import time

dirweb = '/home/jamietam/web-interface-shg-policy/'# Directory contains age eff$
dirresults = '/home/jamietam/mla_results/'

scenarioDict = {'0':{'mla_age':[19],
                      'pac19':[0.00,0.25,0.50,0.75,1.00]
                      'pac21':[0.00],
                      'years':range(2016,2021)
                      },
               '1':{'mla_age':[19],
                      'pac19':[0.00,0.25,0.50,0.75],
                      'pac21':[0.25],
                      'years':range(2016,2021)
                      },
               '2':{'mla_age':[19],
                      'pac19':[0.00,0.25,0.50],
                      'pac21':[0.50],
                      'years':range(2016,2021)
                      },
               '3':{'mla_age':[19],
                      'pac19':[0.00,0.25],
                      'pac21':[0.75],
                      'years':range(2016,2021)
                      },
               '4':{'mla_age':[19],
                      'pac19':[0.00],
                      'pac21':[1.00],
                      'years':range(2016,2021)
                      },
        	'5':{'mla_age':[21],
                      'pac19':[0.00,0.25,0.50,0.75,1.00]
                      'pac21':[0.00],
                      'years':range(2016,2021)
                      },
               '6':{'mla_age':[21],
                      'pac19':[0.00,0.25,0.50,0.75],
                      'pac21':[0.25],
                      'years':range(2016,2021)
                      },
               '7':{'mla_age':[21],
                      'pac19':[0.00,0.25,0.50],
                      'pac21':[0.50],
                      'years':range(2016,2021)
                      },
               '8':{'mla_age':[21],
                      'pac19':[0.00,0.25],
                      'pac21':[0.75],
                      'years':range(2016,2021)
                      },
               '9':{'mla_age':[21],
                      'pac19':[0.00],
                      'pac21':[1.00],
                      'years':range(2016,2021)
                      },
		'10':{'mla_age':[25],
                      'pac19':[0.00,0.25,0.50,0.75,1.00]
                      'pac21':[0.00],
                      'years':range(2016,2021)
                      },
               '11':{'mla_age':[25],
                      'pac19':[0.00,0.25,0.50,0.75],
                      'pac21':[0.25],
                      'years':range(2016,2021)
                      },
               '12':{'mla_age':[25],
                      'pac19':[0.00,0.25,0.50],
                      'pac21':[0.50],
                      'years':range(2016,2021)
                      },
               '13':{'mla_age':[25],
                      'pac19':[0.00,0.25],
                      'pac21':[0.75],
                      'years':range(2016,2021)
                      },
               '14':{'mla_age':[25],
                      'pac19':[0.00],
                      'pac21':[1.00],
                      'years':range(2016,2021)
                      },
}


def policyrun (mla_age_set,pac19_set,pac21_set,years_set,directory):
    combos = product(mla_age_set,pac19_set,pac21_set,years_set)
    numscenarios = 0
    for scen in list(combos):
        dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(directory) # Directory contains 'policy_shg.py'
        dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
        # Create policy inputs file
        os.chdir(dirweb)
        os.system("Rscript create_mla_params_file.R %s %s %s %0.2f %0.2f %0.2f %s" % scen)

        ## Males
        cmd1="mv inputsmla_males_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv " % scen # move file to policy module inputs folder
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
        cmd3="mv inputsmla_females_w%s_r%s_b%s_w%0.2f_r%0.2f_b%0.2f_%s.csv " % scen
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

if __name__ == '__main__':
    # cpus = mp.cpu_count()
    pool = mp.Pool(processes=15)
    for key, scenario in scenarioDict.items():
        directory = key
        print("ITERATION: "+ directory)

        mla_age_set = scenario['mla_age'] 
        pac19_set = scenario['pac19']
        pac21_set = scenario['pac21']
        years_set = scenario['years'] ## Year of policy implementation
        pool.apply_async(policyrun, args=(mla_age_set,pac19_set,pac21_set,years_set,directory))

    pool.close() #closes the pool and prevents you from submitting any more jobs
    pool.join() # waits for all the jobs to finish before moving onto the next line of code

