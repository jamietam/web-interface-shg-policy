from glob import glob
import os
import shutil


files_to_remove = glob('input_*')
files_to_remove.append('prevalences.csv')
files_to_remove.append('results.csv')
files_to_remove.append('lbc_smokehist.exe')


for file_to_remove in files_to_remove:
    try:
        os.remove(file_to_remove)
    except:
        pass

try:
    shutil.rmtree('runs')
except:
    pass

try:
    os.system("find . -name '*.pyc' -print0 | xargs -0 rm")
except:
    pass
