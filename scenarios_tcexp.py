import os
import csv
import sys
from itertools import product
import multiprocessing as mp
import time

dirweb = '/home/jamietam/web-interface-shg-policy/'# Directory contains age eff$
dirresults = '/home/jamietam/tcexp_results/'

scenarioDict = {'0':{'initexp':[0.00],
                      'finalexp':[0.10,0.20,0.30,0.40,0.50],
                      'years':range(2016,2021)
			}
		'1':{'initexp':[0.00],
                      'finalexp':[0.60,0.70,0.80,0.90,1.00],
                      'years':range(2016,2021)
			}
		'2':{'initexp':[0.10],
                      'finalexp':[0.20,0.30,0.40,0.50],
                      'years':range(2016,2021)
			}
                '3':{'initexp':[0.10],
                      'finalexp':[0.60,0.70,0.80,0.90,1.00],
                      'years':range(2016,2021)
                        }
                '4':{'initexp':[0.20],
                      'finalexp':[0.30,0.40,0.50,0.60],
                      'years':range(2016,2021)
                        }
                '5':{'initexp':[0.20],
                      'finalexp':[0.70,0.80,0.90,1.00],
                      'years':range(2016,2021)
                        }
                '6':{'initexp':[0.30],
                      'finalexp':[0.40,0.50,0.60,0.70],
                      'years':range(2016,2021)
                        }
                '7':{'initexp':[0.30],
                      'finalexp':[0.80,0.90,1.00],
                      'years':range(2016,2021)
                        }
                '8':{'initexp':[0.40],
                      'finalexp':[0.50,0.60,0.70],
                      'years':range(2016,2021)
                        }
                '9':{'initexp':[0.40],
                      'finalexp':[0.80,0.90,1.00],
                      'years':range(2016,2021)
                        }
                '10':{'initexp':[0.50],
                      'finalexp':[0.60,0.70,0.80,0.90,1.00],
                      'years':range(2016,2021)
                        }
                '11':{'initexp':[0.60],
                      'finalexp':[0.70,0.80,0.90,1.00],
                      'years':range(2016,2021)
                        }
                '12':{'initexp':[0.70],
                      'finalexp':[0.80,0.90,1.00],
                      'years':range(2016,2021)
                        }
                '13':{'initexp':[0.80,0.90],
                      'finalexp':[0.90,1.00],
                      'years':range(2016,2021)
                        }
		}


def policyrun (initexp_set,finalexp_set,years_set,directory):
    combos = product(initexp_set,finalexp_set,years_set)
    numscenarios = 0
    for scen in list(combos):
        dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(directory) # Directory contains 'policy_shg.py'
        dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
        # Create policy inputs file
        os.chdir(dirweb)
	os.system("Rscript create_tcexp_params_file.R %0.2f %0.2f %s" % scen)

        ## Males
	cmd1="mv inputstcexp_males_%0.2f_t%0.2f_%s.csv " % scen #move file to policy module inputs folder
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
	cmd3="mv inputstcexp_females_%0.2f_t%0.2f_%s.csv " % scen
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

        initexp_set = scenario['initexp']
        finalexp_set = scenario['finalexp']
        years_set = scenario['years'] ## Year of policy implementation
        pool.apply_async(policyrun, args=(initexp_set,finalexp_set,years_set,directory))

    pool.close() #closes the pool and prevents you from submitting any more jobs
    pool.join() # waits for all the jobs to finish before moving onto the next line of code
