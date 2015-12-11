from numpy import arange
import platform

version = 'v6.2.4'
if platform.system() == 'Windows':
    exe_name = 'lbc_smokehist_win64.exe'
elif platform.system() == 'Darwin':
    exe_name = 'lbc_smokehist_osx64.exe'
elif platform.system == 'Linux':
    exe_name = 'lbc_smokehist_linux64.exe'


input_folder = '.'
templates_folder = 'templates'
src_folder = 'data/' + version
dest_folder = src_folder + '/mod'
ages = arange(100)
cohorts = arange(1890, 2021)
years = arange(1890, 2120)

untouched_input_files = [
    'lbc_smokehist_cpd.txt',
    'lbc_smokehist_cpdintensityprobs.txt',
    'lbc_smokehist_oc_mortality.txt'
]
