import os
import csv
import sys
from itertools import product
import multiprocessing as mp
import time

dirweb = '/home/jamietam/web-interface-shg-policy/'# Directory contains age eff$
dirresults = '/home/jamietam/taxes_results/'

scenarioDict = {'0':{'initprice':[4.00],
                      'tax':[0.00,1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
			},
		'1':{'initprice':[4.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
			},
		'2':{'initprice':[5.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
			},
                '3':{'initprice':[5.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
                        },
                '4':{'initprice':[6.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
                        },
                '5':{'initprice':[6.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
                        },
                '6':{'initprice':[7.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
                        },
                '7':{'initprice':[7.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
                        },
                '8':{'initprice':[8.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
                        },
                '9':{'initprice':[8.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
                        },
                '10':{'initprice':[9.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
                        },
                '11':{'initprice':[9.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
                        },
                '12':{'initprice':[10.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
                        },
                '13':{'initprice':[10.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':range(2016,2021)
                        }
		}


def policyrun (initprice_set,tax_set,years_set,directory):
    combos = product(initprice_set,tax_set,years_set)
    numscenarios = 0
    for scen in list(combos):
        dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(directory) # Directory contains 'policy_shg.py'
        dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
        # Create policy inputs file
        os.chdir(dirweb)
	os.system("Rscript create_taxes_params_file.R %0.2f %0.2f %s" % scen)

        ## Males
	cmd1="mv inputstax_males_%0.2f_t%0.2f_%s.csv " % scen #move file to policy module inputs folder
        cmd1=cmd1+dirinputs+"policies.csv"
        os.system(cmd1)
        os.chdir(dirinputs)
        os.system("cp demographics_males_200000.csv demographics.csv")
        os.chdir(dirsim)

        runitM = "python policy_shg.py >> ../logM{0}.txt 2>> ../errorM{0}.txt".format(directory) ### NAME THESE AS THE SCENARIO
        os.system(runitM) # run policy module

	cmd2="mv prevalences.csv "+dirresults+"prevalences_males_%0.2f_t%0.2f_%s.csv" % scen
        os.system(cmd2)

        ## Females
        os.chdir(dirweb)
	cmd3="mv inputstax_females_%0.2f_t%0.2f_%s.csv " % scen
        cmd3=cmd3+dirinputs+"policies.csv"
        os.system(cmd3)
        os.chdir(dirinputs)
        os.system("cp demographics_females_200000.csv demographics.csv")
        os.chdir(dirsim)

        runitF = "python policy_shg.py >> ../logF{0}.txt 2>> ../errorF{0}.txt".format(directory)
        os.system(runitF) # run policy module
	cmd4="mv prevalences.csv "+dirresults+"prevalences_females_%0.2f_t%0.2f_%s.csv" % scen
        os.system(cmd4)
        numscenarios = numscenarios+1
    print ("directory " + str(directory)+" = " + str(numscenarios)+ " scenarios")
    print >>sys.stderr, "Done with all combos={}".format(directory)
    print scen

if __name__ == '__main__':
    # cpus = mp.cpu_count()
    pool = mp.Pool(processes=14)
    for key, scenario in scenarioDict.items():
        directory = key
        print("ITERATION: "+ directory)

        initprice_set = scenario['initprice']
        tax_set = scenario['tax']
        years_set = scenario['years'] ## Year of policy implementation
        pool.apply_async(policyrun, args=(initprice_set,tax_set,years_set,directory))

    pool.close() #closes the pool and prevents you from submitting any more jobs
    pool.join() # waits for all the jobs to finish before moving onto the next line of code
