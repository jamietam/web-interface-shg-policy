import os
import time

numThreads = 1
for i in xrange(numThreads):
   dir = "/home/jamietam/shg-policy-module_parallel/"
   cmd = "cp -Tr "+dir+" /home/jamietam/shg-policy-module_parallel_%s &" % (str(i))
#   cmd2 = "cp -Tr /home/jamietam/scenarios_parallel/ /home/jamietam/scenarios_parallel_%s &" % (str(i))
   os.system(cmd)
   time.sleep(30)
#   os.system(cmd2)

#time.sleep(30) # Wait for 30 seconds

for j in xrange(numThreads):
#   cmd3 = "python /home/jamietam/web-interface-shg-policy/tcexp_scenarios_%s.py > " % (str(j))
   cmd3 = "python /home/jamietam/web-interface-shg-policy/tax_scenarios_%s.py >" % (str(j))
   cmd3 = cmd3+"/home/jamietam/log-%s 2>> /home/jamietam/std.out-log-%s &" % (str(j),str(j))

   out = "echo submitting run %s" % str(j)
   os.system(out)
   os.system(cmd3)


