import os
import os.path
from numpy import arange, array
import platform

version = 'v6.3.3'
if platform.system() == 'Windows':
    exe_name = 'lbc_smokehist_win.exe'
elif platform.system() == 'Darwin':
    exe_name = 'lbc_smokehist_osx.exe'
elif platform.system() == 'Linux':
    exe_name = 'lbc_smokehist_linux.exe'

input_folder = '.'
templates_folder = 'templates'
ages = arange(100)

data_directory = '10_28_2014'
src_folder = 'data/' + data_directory
dest_folder = src_folder + '/mod'

untouched_input_files = os.listdir(os.path.join('data', data_directory))
untouched_input_files = [ifile for ifile in untouched_input_files if ifile != 'mod']

# Extract the cohort ranges from the initiation file, assuming that the others are properly matching
input_files = os.listdir(src_folder)
for input_file in input_files:
    if 'init' in input_file:
        init_file = input_file

init_data = open(os.path.join(src_folder, init_file), 'r').readlines()
num_header_lines = int(init_data[0])

cohorts = []
for column in init_data[num_header_lines].split(','):
    try:
        cohort = int(column.split('-')[0])
        cohorts.append(cohort)
    except:
      pass

min_cohort = array(cohorts).min()
max_cohort = array(cohorts).max()

cohorts = arange(min_cohort, max_cohort)
years = arange(min_cohort, max_cohort + max(ages))
