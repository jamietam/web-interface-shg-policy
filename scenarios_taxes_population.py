import os
import csv
import sys
from itertools import product
import multiprocessing as mp
import time


#dirweb = '/Users/rafaelmeza/Documents/web-interface-shg-policy'
#dirresults = '/Users/rafaelmeza/Documents/taxes_results/'

dirs=open('Directories', 'r').readlines()
dirweb=dirs[1].strip().split('=')[1]  # web interface directory
dirresults = dirs[3].strip().split('=')[1]  # taxes results directory
dirtcp=dirs[0].strip().split('=')[1]  ## tcp tool directory

scenarioDict = {'0':{'initprice':[4.00],
                      'tax':[0.00,1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
			},
		'1':{'initprice':[4.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
			},
		'2':{'initprice':[5.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
			},
                '3':{'initprice':[5.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
                        },
                '4':{'initprice':[6.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
                        },
                '5':{'initprice':[6.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
                        },
                '6':{'initprice':[7.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
                        },
                '7':{'initprice':[7.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
                        },
                '8':{'initprice':[8.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
                        },
                '9':{'initprice':[8.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
                        },
                '10':{'initprice':[9.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
                        },
                '11':{'initprice':[9.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
                        },
                '12':{'initprice':[10.00],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
                        },
                '13':{'initprice':[10.50],
                      'tax':[1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00],
                      'years':[2016,2017,2018,2019,2020]
                        }
		}


def policyrun (initprice_set,tax_set,years_set,directory):
    combos = product(initprice_set,tax_set,years_set)
    numscenarios = 0
    for scen in list(combos):
#        dirsim = '/home/jamietam/shg-policy-module_parallel_{}/'.format(directory) # Directory contains 'policy_shg.py'
        dirsim =dirtcp# Directory contains 'policy_shg.py'
        dirinputs = dirsim + 'inputs/' # Directory contains 'policies.csv' and 'demographics.csv'
        # Create policy inputs file
        os.chdir(dirweb)
	os.system("Rscript create_taxes_params_file.R %0.2f %0.2f %s" % scen)

        ##  Run scenario - both sexes at once since effects don't differ
	cmd1="mv inputstax_males_%0.2f_t%0.2f_%s.csv " % scen #move file to policy module inputs folder
        cmd1=cmd1+dirinputs+"policies.csv"
        os.system(cmd1)
        os.chdir(dirsim)

        runitMF = "python policy_popmodel.py >> ../logM{0}.txt 2>> ../errorM{0}.txt".format(directory) ### NAME THESE AS THE SCENARIO
        os.system(runitMF) # run policy module

	cmd2="mv prevalences_males.csv "+dirresults+"prevalences_males_%0.2f_t%0.2f_%s.csv" % scen
        os.system(cmd2)
        cmd3="mv prevalences_females.csv "+dirresults+"prevalences_females_%0.2f_t%0.2f_%s.csv" % scen
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

        initprice_set = scenario['initprice']
        tax_set = scenario['tax']
        years_set = scenario['years'] ## Year of policy implementation
        pool.apply_async(policyrun, args=(initprice_set,tax_set,years_set,directory))

    pool.close() #closes the pool and prevents you from submitting any more jobs
    pool.join() # waits for all the jobs to finish before moving onto the next line of code

## NEXT STEP: Generate TCP tool files at US-level with tcptool_airlaws_data.R

