#!/usr/bin/env python3
import os
import csv
import sys
from itertools import product
import multiprocessing as mp
import time

cohortsize = 50
lastcohort = 2060

this_dir=os.getcwd()
dirweb = this_dir+'/inputdir'
dirresults = this_dir+'/results'
dirsim_base=this_dir+'/dirsim_'
# policy_script_py="/usr/bin/time -a -o "+os.path.join(this_dir,"policy_script.py.timing")+" "+os.path.join(this_dir,'policy_shg.py')
policy_script_py=os.path.join(this_dir,'policy_shg.py')

create_mla_params_rscript='Rscript ' + this_dir + '/create_mla_params_file.R'
csv_inputs_dir=this_dir + '/demographics'

scenarioDicts= [    
                    {'mla_age':[19],                         
                      'pac19':[0.00,0.25,0.50,0.75,1.00],    
                      'pac21':[0.00],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                   {'mla_age':[19],                          
                      'pac19':[0.00,0.25,0.50,0.75],         
                      'pac21':[0.25],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                   {'mla_age':[19],                          
                      'pac19':[0.00,0.25,0.50],              
                      'pac21':[0.50],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                   {'mla_age':[19],                          
                      'pac19':[0.00,0.25],                   
                      'pac21':[0.75],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                   {'mla_age':[19],                          
                      'pac19':[0.00],                        
                      'pac21':[1.00],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                    {'mla_age':[21],                         
                      'pac19':[0.00,0.25,0.50,0.75,1.00],    
                      'pac21':[0.00],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                   {'mla_age':[21],                          
                      'pac19':[0.00,0.25,0.50,0.75],         
                      'pac21':[0.25],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                   {'mla_age':[21],                          
                      'pac19':[0.00,0.25,0.50],              
                      'pac21':[0.50],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                   {'mla_age':[21],                          
                      'pac19':[0.00,0.25],                   
                      'pac21':[0.75],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                   {'mla_age':[21],                          
                      'pac19':[0.00],                        
                      'pac21':[1.00],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                     {'mla_age':[25],                        
                      'pac19':[0.00,0.25,0.50,0.75,1.00],    
                      'pac21':[0.00],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                    {'mla_age':[25],                         
                      'pac19':[0.00,0.25,0.50,0.75],         
                      'pac21':[0.25],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                    {'mla_age':[25],                         
                      'pac19':[0.00,0.25,0.50],              
                      'pac21':[0.50],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                    {'mla_age':[25],                         
                      'pac19':[0.00,0.25],                   
                      'pac21':[0.75],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },                                     
                    {'mla_age':[25],                         
                      'pac19':[0.00],                        
                      'pac21':[1.00],                        
                      'years':[2016,2017,2018,2019,2020]     
                      },
]                                                            

def run_system(cmd):
    """Run a command `cmd` via system(), raise exception if the return code is not zero"""
    rc=os.system(cmd)
    if rc!=0:
        raise RuntimeError("Command '{}' terminated with return code {}".format(cmd,rc))
    return rc

def policyrun (mla_age_set,pac19_set,pac21_set,years_set,directory): 
    combos = product(mla_age_set, pac19_set, pac21_set, years_set)
    numscenarios = 0
    combos_list = list(combos)
    print("DEBUG: We have {} scenarios".format(len(combos_list)))
    for scen in combos_list:
        dirsim = dirsim_base+directory+'/'
        dirinputs = dirsim + 'inputs'

        run_system("mkdir -pv "+dirinputs)
        os.chdir(dirinputs)

        run_system(create_mla_params_rscript + ' %s %0.2f %0.2f %s' % scen)

        cmd = "mv inputsmla_males_%s_pac19_%0.2f_pac21_%0.2f_%s.csv policies.csv" % scen
        run_system(cmd)
        cmd="cp {}/demographics_males_{}_{}.csv demographics.csv".format(csv_inputs_dir, cohortsize, lastcohort)
        run_system(cmd)

        os.chdir(dirsim)

        runitM = policy_script_py +" >> ../logM{0}.txt 2>> ../errorM{0}.txt".format(directory)
        ## DEBUG
        #runitM = 'python3 -m pdb '+policy_script_py

        # # DEBUG!!!
        # raise RuntimeError("DEBUG: About to run {}".format(runitM))
        run_system(runitM)
        cmd = "mv prevalences.csv " + dirresults \
            + "prevalences_males_%s_pac19_%0.2f_pac21_%0.2f_%s.csv" \
            % scen
        run_system(cmd)


        ## Females
        os.chdir(dirinputs)
        cmd = "mv inputsmla_females_%s_pac19_%0.2f_pac21_%0.2f_%s.csv %s/policies.csv" % (*scen,dirinputs)
        run_system(cmd)
        run_system("cp {}/demographics_females_{}_{}.csv demographics.csv".format(csv_inputs_dir,cohortsize,lastcohort))
        os.chdir(dirsim)
        
        runitF = policy_script_py + " >> ../logF{0}.txt 2>> ../errorF{0}.txt".format(directory)
        run_system(runitF) # run policy module
        cmd4="mv prevalences.csv "+dirresults+"prevalences_females_%s_pac19_%0.2f_pac21_%0.2f_%s.csv" % scen
        run_system(cmd4)
        numscenarios = numscenarios+1
    
    print("directory " + str(directory)+" = " + str(numscenarios)+ " scenarios")
    print("Done with all combos={}".format(directory), file=sys.stderr)
    #print(scen)

# cpus = mp.cpu_count()

if __name__ == '__main__':
    ncpus=0  # set to >0 to run in parallel # (FIXME: make it an input argument)
    # e.g.:
    # ncpus=15
    
    pool=None 
    if ncpus>0:
        pool = mp.Pool(processes=ncpus) 
    
    for key, scenario in enumerate(scenarioDicts):
        directory = str(key)
        print("ITERATION: "+ directory)
        
        mla_age_set = scenario['mla_age']
        pac19_set = scenario['pac19']
        pac21_set = scenario['pac21']
        years_set = scenario['years'] ## Year of policy implementation
        if pool:
            pool.apply_async(policyrun, args=(mla_age_set, pac19_set,
                                              pac21_set, years_set, directory))
        else:
            policyrun(mla_age_set,pac19_set,pac21_set,years_set,directory)

    if pool:
        pool.close() #closes the pool and prevents you from submitting any more jobs
        pool.join() # waits for all the jobs to finish before moving onto the next line of code

## NEXT STEP: Generate TCP tool files at US-level with tcptool_mla_data.R
