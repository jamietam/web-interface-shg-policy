import os
import time

numThreads = 20
for i in xrange(numThreads):
   dir = "/home/jamietam/shg-policy-module_parallel/"
   cmd = "cp -Tr "+dir+" /home/jamietam/shg-policy-module_parallel_%s &" % (str(i))
   os.system(cmd)
   time.sleep(30) # Wait for 30 seconds in between


