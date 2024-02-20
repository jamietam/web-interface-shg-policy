import os
import csv
import sys
from itertools import product
import multiprocessing as mp
import time

#dirweb = '/Users/rafaelmeza/Documents/web-interface-shg-policy'
#dirresults = '/Users/rafaelmeza/Documents/mla_results/'

dirs=open('Directories', 'r').readlines()
dirweb=dirs[1].strip().split('=')[1]  # web interface directory
dirresults = dirs[6].strip().split('=')[1]  # mla results directory
dirtcp=dirs[0].strip().split('=')[1]  ## tcp tool directory

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
       dirsim =dirtcp# Directory contains 'policy_shg.py'
       #dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(directory) # Directory contains 'policy_shg.py'
       dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
       # # Create policy inputs file
       os.chdir(dirweb)
       os.system("Rscript create_mla_params_file.R %s %0.2f %0.2f %s" % scen)
       
       ##  Run scenario - both sexes at once since effects don't differ
       cmd1="mv inputsmla_males_%s_pac19_%0.2f_pac21_%0.2f_%s.csv " % scen
       cmd1=cmd1+dirinputs+"policies.csv"
       
       os.system(cmd1)
       os.chdir(dirsim)
       
       runitMF = "python policy_popmodel.py >> ../logM{0}.txt 2>> ../errorM{0}.txt".format(directory) ### NAME THESE AS THE SCENARIO
       os.system(runitMF) # run policy module
       
       cmd2="mv prevalences_males.csv "+dirresults+"prevalences_males_%s_pac19_%0.2f_pac21_%0.2f_%s.csv" % scen
       os.system(cmd2)
       cmd3="mv prevalences_females.csv "+dirresults+"prevalences_females_%s_pac19_%0.2f_pac21_%0.2f_%s.csv" % scen
       os.system(cmd3)
       numscenarios = numscenarios+1
    print ("directory " + str(directory)+" = " + str(numscenarios)+ " scenarios")
    print >>sys.stderr, "Done with all combos={}".format(directory)
    print scen

if __name__ == '__main__':
    # cpus = mp.cpu_count()
    pool = mp.Pool(processes=1)
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

