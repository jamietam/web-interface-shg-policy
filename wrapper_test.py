import os
numThreads = 2
for i in xrange(numThreads):
   dir = "/home/jamietam/shg-policy-module_parallel/"
   cmd = "cp -Tr "+dir+" /home/jamietam/shg-policy-module_parallel_%s &" % (str(i))
   cmd2 = "cp -Tr /home/jamietam/scenarios_parallel/ /home/jamietam/scenarios_parallel_%s &" % (str(i))
   os.system(cmd)
   os.system(cmd2)


# specify which parameters to use for each thread
# scen=(Iwp, Ir, Ib, pacwp, pacr, pacb)
scen1 = (1,1,1,0.0,1.0,0.5)
scen2 = (1,1,1,0.75,0.75,0.75)
scenario_set = (scen1,scen2)

for j in xrange(numThreads):
   #cmd3 = "sudo python /home/jamietam/scenarios_parallel_%s/test_Run_4000_scenarios_test.py %s > test-%s 2>> std.out-test-%s &" % (str(j), str(j), str(j), str(j))
   cmd3 = "sudo python /home/jamietam/web-interface-shg-policy/Run_4000_scenarios_test.py %s " % str(j)
   cmd3 = cmd3+"%s %s %s %s %s %s> " % scenario_set[j]
   cmd3 = cmd3+"test-%s 2>> std.out-test-%s &" % (str(j), str(j))

   out = "echo submitting run %s" % str(j)   
   os.system(out)
   os.system(cmd3)
