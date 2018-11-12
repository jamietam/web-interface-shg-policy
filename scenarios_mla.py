import os
import csv
import sys
from itertools import product
import multiprocessing as mp
import time

cohortsize = 50
lastcohort = 2060
dirweb = '/home/jamietam/web-interface-shg-policy/'
dirresults = '/home/jamietam/mla_results/'

scenarioDict = {'0':{'mla_age':[19],
                      'pac19':[0.00,0.25,0.50,0.75,1.00],
                      'pac21':[0.00],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '1':{'mla_age':[19],
                      'pac19':[0.00,0.25,0.50,0.75],
                      'pac21':[0.25],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '2':{'mla_age':[19],
                      'pac19':[0.00,0.25,0.50],
                      'pac21':[0.50],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '3':{'mla_age':[19],
                      'pac19':[0.00,0.25],
                      'pac21':[0.75],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '4':{'mla_age':[19],
                      'pac19':[0.00],
                      'pac21':[1.00],
                      'years':[2016,2017,2018,2019,2020]
                      },
        	'5':{'mla_age':[21],
                      'pac19':[0.00,0.25,0.50,0.75,1.00],
                      'pac21':[0.00],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '6':{'mla_age':[21],
                      'pac19':[0.00,0.25,0.50,0.75],
                      'pac21':[0.25],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '7':{'mla_age':[21],
                      'pac19':[0.00,0.25,0.50],
                      'pac21':[0.50],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '8':{'mla_age':[21],
                      'pac19':[0.00,0.25],
                      'pac21':[0.75],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '9':{'mla_age':[21],
                      'pac19':[0.00],
                      'pac21':[1.00],
                      'years':[2016,2017,2018,2019,2020]
                      },
		'10':{'mla_age':[25],
                      'pac19':[0.00,0.25,0.50,0.75,1.00],
                      'pac21':[0.00],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '11':{'mla_age':[25],
                      'pac19':[0.00,0.25,0.50,0.75],
                      'pac21':[0.25],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '12':{'mla_age':[25],
                      'pac19':[0.00,0.25,0.50],
                      'pac21':[0.50],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '13':{'mla_age':[25],
                      'pac19':[0.00,0.25],
                      'pac21':[0.75],
                      'years':[2016,2017,2018,2019,2020]
                      },
               '14':{'mla_age':[25],
                      'pac19':[0.00],
                      'pac21':[1.00],
                      'years':[2016,2017,2018,2019,2020]
                      }
}


def policyrun (mla_age_set,pac19_set,pac21_set,years_set,directory):
    combos = product(mla_age_set,pac19_set,pac21_set,years_set)
    numscenarios = 0
    for scen in list(combos):
        dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(directory) # Directory contains 'policy_shg.py'
        dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
        # Create policy inputs file
        os.chdir(dirweb)
        os.system("Rscript create_mla_params_file.R %s %0.2f %0.2f %s" % scen)

        ## Males
        cmd1="mv inputsmla_males_%s_pac19_%0.2f_pac21_%0.2f_%s.csv " % scen
        cmd1=cmd1+dirinputs+"policies.csv"
        os.system(cmd1)
        demoM ="cp "+dirweb+"demographics_males_"+str(cohortsize)+"_" +str(lastcohort)+".csv "+dirinputs+"demographics.csv"
        os.system(demoM)
        os.chdir(dirsim)

        runitM = "python policy_shg.py >> ../logM{0}.txt 2>> ../errorM{0}.txt".format(directory) ### NAME THESE AS THE SCENARIO
        os.system(runitM) # run policy module

        cmd2="mv prevalences.csv "+dirresults+"prevalences_males_%s_pac19_%0.2f_pac21_%0.2f_%s.csv" % scen
        os.system(cmd2)

        ## Females
        os.chdir(dirweb)
        cmd3="mv inputsmla_females_%s_pac19_%0.2f_pac21_%0.2f_%s.csv " % scen
        cmd3=cmd3+dirinputs+"policies.csv"
        os.system(cmd3)
        demoF ="cp "+dirweb+"demographics_females_"+str(cohortsize)+"_" +str(lastcohort)+".csv "+dirinputs+"demographics.csv"
        os.system(demoF)
        os.chdir(dirsim)

        runitF = "python policy_shg.py >> ../logF{0}.txt 2>> ../errorF{0}.txt".format(directory)
        os.system(runitF) # run policy module

        cmd4="mv prevalences.csv "+dirresults+"prevalences_females_%s_pac19_%0.2f_pac21_%0.2f_%s.csv" % scen
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

## NEXT STEP: Generate TCP tool files at US-level with tcptool_mla_data.R

